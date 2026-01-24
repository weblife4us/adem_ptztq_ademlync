import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/calibration_manager.dart';
import '../../utils/controllers/param_format_manager.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';

class Calibration1PointDpPageBloc
    extends Bloc<Calibration1PointDpPageEvent, Calibration1PointDpPageState>
    with AdemActionHelper, CalibrationManager {
  int _fetchCount = 0;
  int _calibCount = 0;

  Calibration1PointDpPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
    on<UpdateData>(_mapUpdateDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<Calibration1PointDpPageState> emit,
  ) async {
    emit(event.isRefresh ? DataRefreshing() : DataFetching());

    final manager = ParamFormatManager();

    try {
      await for (final o in streamCalibration([..._params])) {
        if (isCancelCommunication) throw CancelAdemCommunication();

        final isDpTxdrMalf = manager.autoDecode(Param.isDpTxdrMalf, o);
        final offsetInKpa = manager.autoDecode(Param.dpCalib1PtOffset, o);
        final counts = manager.autoDecode(Param.pressADReadCounts, o);
        final dp = manager.autoDecode(Param.diffPress, o);

        if (isDpTxdrMalf ||
            offsetInKpa is! double ||
            counts is! int ||
            dp is! double) {
          final str = [
            'Please double-check or consider switching to another AdEM',
            if (isDpTxdrMalf) '- D.P. transducer malfunction',
            if (offsetInKpa is! double) '- Offset not found',
            if (counts is! int) '- A/D reading counts not found',
            if (dp is! double) '- D.P. not found',
          ];

          throw AdemCommError(
            AdemCommErrorType.calibrationNullParam,
            str.join('\n'),
          );
        }

        final offset = switch (AppDelegate().adem.meterSystem) {
          MeterSystem.imperial => kpaToInH2o(offsetInKpa),
          MeterSystem.metric => offsetInKpa,
        };

        final info = DpCalib1Pt(counts, dp, offset / dpCalibOffset);

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
    Emitter<Calibration1PointDpPageState> emit,
  ) async {
    emit(DataUpdating());

    double offset = event.trueDp - event.dp + event.offset;
    offset = switch (AppDelegate().adem.meterSystem) {
      MeterSystem.imperial => inH2oToKpa(offset),
      MeterSystem.metric => offset,
    };
    offset *= dpCalibOffset;

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

abstract class Calibration1PointDpPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends Calibration1PointDpPageEvent {
  final bool isRefresh;

  FetchData([this.isRefresh = true]);
}

class UpdateData extends Calibration1PointDpPageEvent {
  final String accessCode;
  final double trueDp;
  final double dp;
  final double offset;

  UpdateData(this.accessCode, this.trueDp, this.dp, this.offset);
}
// ---- State ----

abstract class Calibration1PointDpPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends Calibration1PointDpPageState {}

class DataFetching extends Calibration1PointDpPageState {}

class DataRefreshing extends Calibration1PointDpPageState {}

class DataFetched extends Calibration1PointDpPageState {
  final int fetchCount;
  final bool isStabled;

  DataFetched(this.fetchCount, this.isStabled);
}

class DataReady extends Calibration1PointDpPageState {
  final DpCalib1Pt info;

  DataReady(this.info);
}

class StreamDone extends Calibration1PointDpPageState {}

class FetchDataFailed extends Calibration1PointDpPageState {
  final Object error;

  FetchDataFailed(this.error);
}

class DataUpdating extends Calibration1PointDpPageState {}

class DataUpdated extends Calibration1PointDpPageState {
  final int calibCount;

  DataUpdated(this.calibCount);
}

class UpdateDataFailed extends Calibration1PointDpPageState {
  final Object error;

  UpdateDataFailed(this.error);
}

const _params = {
  Param.isDpTxdrMalf,
  Param.pressADReadCounts,
  Param.diffPress,
  Param.dpCalib1PtOffset,
};
