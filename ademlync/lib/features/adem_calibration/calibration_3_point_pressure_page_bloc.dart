import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/calibration_manager.dart';
import '../../utils/controllers/param_format_manager.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';

class Calibration3PointPressurePageBloc
    extends
        Bloc<
          Calibration3PointPressurePageEvent,
          Calibration3PointPressurePageState
        >
    with AdemActionHelper, CalibrationManager {
  int _fetchCount = 0;
  int _calibCount = 0;

  Calibration3PointPressurePageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
    on<UpdateData>(_mapUpdateDataToState);
  }

  Adem get _adem => AppDelegate().adem;
  bool get _isAbs => _adem.isAbsPressTrans;
  Param get _pressParam => _isAbs ? Param.absPress : Param.gaugePress;
  PressUnit? get _pressUnit => _adem.measureCache.pressUnit;

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<Calibration3PointPressurePageState> emit,
  ) async {
    emit(event.isRefresh ? DataRefreshing() : DataFetching());

    final manager = ParamFormatManager();

    try {
      await for (final o in streamCalibration([..._params, _pressParam])) {
        if (isCancelCommunication) throw CancelAdemCommunication();

        final isPressTxdrMalf = manager.autoDecode(Param.isPressTxdrMalf, o);
        final cStr = decodeBleResponseBodyFor3ptCalibration(
          o[Param.threePtPressCalibParams],
        );
        final counts = manager.autoDecode(Param.pressADReadCounts, o);
        final press = manager.autoDecode(_pressParam, o);

        if (isPressTxdrMalf ||
            cStr == null ||
            counts is! int ||
            press is! double ||
            _pressUnit == null) {
          final str = [
            'Please double-check or consider switching to another AdEM',
            if (isPressTxdrMalf) '- Pressure transducer malfunction',
            if (cStr == null) '- 3 point calibration parameters not found',
            if (counts is! int) '- A/D reading counts not found',
            if (press is! double) '- Pressure not found',
            if (_pressUnit == null) '- Pressure unit not found',
          ];

          throw AdemCommError(
            AdemCommErrorType.calibrationNullParam,
            str.join('\n'),
          );
        }

        final config = Calib3PtConfig.from(
          cStr,
        ).fromKpaToPressUnit(_pressUnit!);

        // Map out the page model
        final info = PressCalib3Pt(
          counts,
          press,
          manager.autoDecode(Param.pressTransRange, o),
          config,
        );

        emit(DataFetched(++_fetchCount, isADRCStable(info.aDReadCounts)));
        emit(DataReady(info));
      }

      emit(StreamDone());
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }

  Future<void> _mapUpdateDataToState(
    UpdateData event,
    Emitter<Calibration3PointPressurePageState> emit,
  ) async {
    emit(DataUpdating());

    final unit = AppDelegate().adem.measureCache.pressUnit!;
    final oldParams = event.config.fromPressUnitToKpa(unit);
    final newParams = event.newConfig.fromPressUnitToKpa(unit);

    final data = newParams.toDataString(oldParams);

    final user = AppDelegate().user;

    try {
      if (user == null) throw NullSafety.user.exception;

      await executeTasks(
        [() => AdemManager().write(Param.threePtPressCalibParams.key, data)],
        accessCode: event.accessCode,
        userId: user.id,
      );

      emit(DataUpdated(++_calibCount));
    } catch (e) {
      emit(UpdateDataFailed(e));
    }
  }
}

// ---- Event ----

abstract class Calibration3PointPressurePageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends Calibration3PointPressurePageEvent {
  final bool isRefresh;

  FetchData([this.isRefresh = true]);
}

class UpdateData extends Calibration3PointPressurePageEvent {
  final String accessCode;
  final Calib3PtConfig config;
  final Calib3PtConfig newConfig;

  UpdateData(this.accessCode, this.config, this.newConfig);
}

// ---- State ----

abstract class Calibration3PointPressurePageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends Calibration3PointPressurePageState {}

class DataFetching extends Calibration3PointPressurePageState {}

class DataRefreshing extends Calibration3PointPressurePageState {}

class DataFetched extends Calibration3PointPressurePageState {
  final int fetchCount;
  final bool isStabled;

  DataFetched(this.fetchCount, this.isStabled);
}

class DataReady extends Calibration3PointPressurePageState {
  final PressCalib3Pt info;

  DataReady(this.info);
}

class StreamDone extends Calibration3PointPressurePageState {}

class FetchDataFailed extends Calibration3PointPressurePageState {
  final Object error;

  FetchDataFailed(this.error);
}

class DataUpdating extends Calibration3PointPressurePageState {}

class DataUpdated extends Calibration3PointPressurePageState {
  final int calibCount;

  DataUpdated(this.calibCount);
}

class UpdateDataFailed extends Calibration3PointPressurePageState {
  final Object error;

  UpdateDataFailed(this.error);
}

const _params = {
  Param.isPressTxdrMalf,
  Param.pressADReadCounts,
  Param.threePtPressCalibParams,
  Param.pressTransRange,
};
