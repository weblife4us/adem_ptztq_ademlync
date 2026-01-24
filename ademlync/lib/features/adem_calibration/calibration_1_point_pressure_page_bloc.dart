import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/calibration_manager.dart';
import '../../utils/controllers/param_format_manager.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';

class Calibration1PointPressurePageBloc
    extends
        Bloc<
          Calibration1PointPressurePageEvent,
          Calibration1PointPressurePageState
        >
    with AdemActionHelper, CalibrationManager {
  int _fetchCount = 0;
  int _calibCount = 0;

  Calibration1PointPressurePageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
    on<UpdateData>(_mapUpdateDataToState);
  }

  Adem get _adem => AppDelegate().adem;
  bool get _isAbs => _adem.isAbsPressTrans;
  Param get _pressParam => _isAbs ? Param.absPress : Param.gaugePress;
  PressUnit? get _pressUnit => _adem.measureCache.pressUnit;

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<Calibration1PointPressurePageState> emit,
  ) async {
    emit(event.isRefresh ? DataRefreshing() : DataFetching());

    final manager = ParamFormatManager();

    try {
      await for (final o in streamCalibration([..._params, _pressParam])) {
        if (isCancelCommunication) throw CancelAdemCommunication();

        final isPressTxdrMalf = manager.autoDecode(Param.isPressTxdrMalf, o);
        final offsetInKpa = manager.autoDecode(Param.pressCalib1PtOffset, o);
        final counts = manager.autoDecode(Param.pressADReadCounts, o);
        final press = manager.autoDecode(_pressParam, o);

        if (isPressTxdrMalf ||
            offsetInKpa is! double ||
            counts is! int ||
            press is! double ||
            _pressUnit == null) {
          final str = [
            'Please double-check or consider switching to another AdEM',
            if (isPressTxdrMalf) '- Pressure transducer malfunction',
            if (offsetInKpa is! double) '- Offset not found',
            if (counts is! int) '- A/D reading counts not found',
            if (press is! double) '- Pressure not found',
            if (_pressUnit == null) '- Pressure unit not found',
          ];

          throw AdemCommError(
            AdemCommErrorType.calibrationNullParam,
            str.join('\n'),
          );
        }

        final offset = switch (_pressUnit!) {
          PressUnit.psi => kpaToPsi(offsetInKpa),
          PressUnit.kpa => offsetInKpa,
          PressUnit.bar => kpaToBar(offsetInKpa),
        };

        final info = PressCalib1Pt(
          counts,
          press,
          manager.autoDecode(Param.pressTransRange, o),
          offset,
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
    Emitter<Calibration1PointPressurePageState> emit,
  ) async {
    emit(DataUpdating());

    double offset = event.truePress - event.gasPress + event.offset;
    offset = switch (AppDelegate().adem.measureCache.pressUnit!) {
      PressUnit.psi => psiaToKpa(offset),
      PressUnit.kpa => offset,
      PressUnit.bar => barToKpa(offset),
    };

    final data = offset.toStringAsFixed(1).replaceAll('.', '').padLeft(8, '0');

    final user = AppDelegate().user;

    try {
      if (user == null) throw NullSafety.user.exception;

      await executeTasks(
        [() => AdemManager().write(Param.pressCalib1PtOffset.key, data)],
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

abstract class Calibration1PointPressurePageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends Calibration1PointPressurePageEvent {
  final bool isRefresh;

  FetchData([this.isRefresh = true]);
}

class UpdateData extends Calibration1PointPressurePageEvent {
  final String accessCode;
  final double truePress;
  final double gasPress;
  final double offset;

  UpdateData(this.accessCode, this.truePress, this.gasPress, this.offset);
}

// ---- State ----

abstract class Calibration1PointPressurePageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends Calibration1PointPressurePageState {}

class DataFetching extends Calibration1PointPressurePageState {}

class DataRefreshing extends Calibration1PointPressurePageState {}

class DataFetched extends Calibration1PointPressurePageState {
  final int fetchCount;
  final bool isStabled;

  DataFetched(this.fetchCount, this.isStabled);
}

class DataReady extends Calibration1PointPressurePageState {
  final PressCalib1Pt info;

  DataReady(this.info);
}

class StreamDone extends Calibration1PointPressurePageState {}

class FetchDataFailed extends Calibration1PointPressurePageState {
  final Object error;

  FetchDataFailed(this.error);
}

class DataUpdating extends Calibration1PointPressurePageState {}

class DataUpdated extends Calibration1PointPressurePageState {
  final int calibCount;

  DataUpdated(this.calibCount);
}

class UpdateDataFailed extends Calibration1PointPressurePageState {
  final Object error;

  UpdateDataFailed(this.error);
}

const _params = {
  Param.isPressTxdrMalf,
  Param.pressADReadCounts,
  Param.pressCalib1PtOffset,
  Param.pressTransRange,
};
