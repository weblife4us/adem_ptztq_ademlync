import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/calibration_manager.dart';
import '../../utils/controllers/param_format_manager.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';

class Calibration1PointTemperaturePageBloc
    extends
        Bloc<
          Calibration1PointTemperaturePageEvent,
          Calibration1PointTemperaturePageState
        >
    with AdemActionHelper, CalibrationManager {
  int _fetchCount = 0;
  int _calibCount = 0;

  Calibration1PointTemperaturePageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
    on<UpdateData>(_mapUpdateDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<Calibration1PointTemperaturePageState> emit,
  ) async {
    emit(event.isRefresh ? DataRefreshing() : DataFetching());

    final manager = ParamFormatManager();

    try {
      await for (final o in streamCalibration([..._params])) {
        if (isCancelCommunication) throw CancelAdemCommunication();

        final isTempTxdrMalf = manager.autoDecode(Param.isTempTxdrMalf, o);
        final offset = manager.autoDecode(Param.tempCalib1PtOffset, o);
        final counts = manager.autoDecode(Param.tempADReadCounts, o);
        final temp = manager.autoDecode(Param.temp, o);

        if (isTempTxdrMalf ||
            offset is! double ||
            counts is! int ||
            temp is! double) {
          final str = [
            'Please double-check or consider switching to another AdEM',
            if (isTempTxdrMalf) '- Temperature transducer malfunction',
            if (offset is! double) '- Offset not found',
            if (counts is! int) '- A/D reading counts not found',
            if (temp is! double) '- Temperature not found',
          ];

          throw AdemCommError(
            AdemCommErrorType.calibrationNullParam,
            str.join('\n'),
          );
        }

        final info = TempCalib1Pt(counts, temp, offset);

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
    Emitter<Calibration1PointTemperaturePageState> emit,
  ) async {
    emit(DataUpdating());

    final offset = event.trueTemp - event.gasTemp + event.offset;

    final data = offset.toAdemStringFmt(decimal: 1);
    final target = 'SSSSSSSS'.replaceAll('S', ' ');

    final user = AppDelegate().user;

    try {
      if (user == null) throw NullSafety.user.exception;

      await executeTasks(
        [
          () => AdemManager().write(Param.tempCalib1PtOffset.key, data),
          () => AdemManager().write(Param.onePtTempTarget.key, target),
        ],
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

abstract class Calibration1PointTemperaturePageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends Calibration1PointTemperaturePageEvent {
  final bool isRefresh;

  FetchData([this.isRefresh = true]);
}

class UpdateData extends Calibration1PointTemperaturePageEvent {
  final String accessCode;
  final double trueTemp;
  final double gasTemp;
  final double offset;

  UpdateData(this.accessCode, this.trueTemp, this.gasTemp, this.offset);
}

// ---- State ----

abstract class Calibration1PointTemperaturePageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends Calibration1PointTemperaturePageState {}

class DataFetching extends Calibration1PointTemperaturePageState {}

class DataRefreshing extends Calibration1PointTemperaturePageState {}

class DataFetched extends Calibration1PointTemperaturePageState {
  final int fetchCount;
  final bool isStabled;

  DataFetched(this.fetchCount, this.isStabled);
}

class DataReady extends Calibration1PointTemperaturePageState {
  final TempCalib1Pt info;

  DataReady(this.info);
}

class StreamDone extends Calibration1PointTemperaturePageState {}

class FetchDataFailed extends Calibration1PointTemperaturePageState {
  final Object error;

  FetchDataFailed(this.error);
}

class DataUpdating extends Calibration1PointTemperaturePageState {}

class DataUpdated extends Calibration1PointTemperaturePageState {
  final int calibCount;

  DataUpdated(this.calibCount);
}

class UpdateDataFailed extends Calibration1PointTemperaturePageState {
  final Object error;

  UpdateDataFailed(this.error);
}

const _params = {
  Param.isTempTxdrMalf,
  Param.tempADReadCounts,
  Param.temp,
  Param.tempCalib1PtOffset,
};
