import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/calibration_manager.dart';
import '../../utils/controllers/param_format_manager.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';

class Calibration3PointDpPageBloc
    extends Bloc<Calibration3PointDpPageEvent, Calibration3PointDpPageState>
    with AdemActionHelper, CalibrationManager {
  int _fetchCount = 0;
  int _calibCount = 0;

  Calibration3PointDpPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
    on<UpdateData>(_mapUpdateDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<Calibration3PointDpPageState> emit,
  ) async {
    emit(event.isRefresh ? DataRefreshing() : DataFetching());

    final manager = ParamFormatManager();

    try {
      // Stream logs
      await for (final o in streamCalibration([..._params])) {
        if (isCancelCommunication) throw CancelAdemCommunication();

        final isDpTxdrMalf = manager.autoDecode(Param.isDpTxdrMalf, o);
        final cStr = decodeBleResponseBodyFor3ptCalibration(
          o[Param.threePtPressCalibParams],
        );
        final counts = manager.autoDecode(Param.pressADReadCounts, o);
        final dp = manager.autoDecode(Param.diffPress, o);

        if (isDpTxdrMalf || cStr == null || counts is! int || dp is! double) {
          final str = [
            'Please double-check or consider switching to another AdEM',
            if (isDpTxdrMalf) '- D.P. transducer malfunction',
            if (cStr == null) '- 3 point calibration parameters not found',
            if (counts is! int) '- A/D reading counts not found',
            if (dp is! double) '- D.P. not found',
          ];

          throw AdemCommError(
            AdemCommErrorType.calibrationNullParam,
            str.join('\n'),
          );
        }

        final config = Calib3PtConfig.from(
          cStr,
        ).fromKpaToDpUnit(AppDelegate().adem.meterSystem);

        final info = DpCalib3Pt(counts, dp, config);

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
    Emitter<Calibration3PointDpPageState> emit,
  ) async {
    emit(DataUpdating());

    final system = AppDelegate().adem.meterSystem;
    final oldParams = event.config.fromDpUnitToKpa(system);
    final newParams = event.newConfig.fromDpUnitToKpa(system);

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

abstract class Calibration3PointDpPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends Calibration3PointDpPageEvent {
  final bool isRefresh;

  FetchData([this.isRefresh = true]);
}

class UpdateData extends Calibration3PointDpPageEvent {
  final String accessCode;
  final Calib3PtConfig config;
  final Calib3PtConfig newConfig;

  UpdateData(this.accessCode, this.config, this.newConfig);
}

// ---- State ----

abstract class Calibration3PointDpPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends Calibration3PointDpPageState {}

class DataFetching extends Calibration3PointDpPageState {}

class DataRefreshing extends Calibration3PointDpPageState {}

class DataFetched extends Calibration3PointDpPageState {
  final int fetchCount;
  final bool isStabled;

  DataFetched(this.fetchCount, this.isStabled);
}

class DataReady extends Calibration3PointDpPageState {
  final DpCalib3Pt info;

  DataReady(this.info);
}

class StreamDone extends Calibration3PointDpPageState {}

class FetchDataFailed extends Calibration3PointDpPageState {
  final Object error;

  FetchDataFailed(this.error);
}

class DataUpdating extends Calibration3PointDpPageState {}

class DataUpdated extends Calibration3PointDpPageState {
  final int calibCount;

  DataUpdated(this.calibCount);
}

class UpdateDataFailed extends Calibration3PointDpPageState {
  final Object error;

  UpdateDataFailed(this.error);
}

const _params = {
  Param.isDpTxdrMalf,
  Param.pressADReadCounts,
  Param.diffPress,
  Param.threePtPressCalibParams,
};
