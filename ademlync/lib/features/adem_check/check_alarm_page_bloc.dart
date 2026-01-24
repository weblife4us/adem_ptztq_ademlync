import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import 'check_alarm_page_model.dart';
import '../../utils/functions.dart';

class CheckAlarmPageBloc extends Bloc<CheckAlarmPageEvent, CheckAlarmPageState>
    with AdemActionHelper {
  CheckAlarmPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<CheckAlarmPageState> emit,
  ) async {
    emit(DataFetching());

    final manager = ParamFormatManager();

    try {
      final map = await fetchForParameters([..._params]);

      if (isCancelCommunication) throw CancelAdemCommunication();

      final info = CheckAlarmPageModel(
        manager.autoDecode(Param.isAlarmOutput, map),
        manager.autoDecode(Param.isPressTxdrMalf, map),
        manager.autoDecode(Param.isPressHigh, map),
        manager.autoDecode(Param.isPressLow, map),
        manager.autoDecode(Param.pressHighLimit, map),
        manager.autoDecode(Param.pressLowLimit, map),
        manager.autoDecode(Param.pressTxdrMalfDate, map),
        manager.autoDecode(Param.pressTxdrMalfTime, map),
        manager.autoDecode(Param.isTempTxdrMalf, map),
        manager.autoDecode(Param.isTempHigh, map),
        manager.autoDecode(Param.isTempLow, map),
        manager.autoDecode(Param.tempHighLimit, map),
        manager.autoDecode(Param.tempLowLimit, map),
        manager.autoDecode(Param.tempTxdrMalfDate, map),
        manager.autoDecode(Param.tempTxdrMalfTime, map),
        manager.autoDecode(Param.isBatteryMalf, map),
        manager.autoDecode(Param.batteryMalfDate, map),
        manager.autoDecode(Param.batteryMalfTime, map),
        manager.autoDecode(Param.isMemoryError, map),
        manager.autoDecode(Param.memoryErrorDate, map),
        manager.autoDecode(Param.memoryErrorTime, map),
        manager.autoDecode(Param.uncVolSinceMalf, map),
        manager.autoDecode(Param.isUncFlowRateHigh, map),
        manager.autoDecode(Param.isUncFlowRateLow, map),
        manager.autoDecode(Param.uncFlowRate, map),
        manager.autoDecode(Param.uncFlowRateHighLimit, map),
        manager.autoDecode(Param.uncFlowRateLowLimit, map),
      );

      emit(DataReady(info));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }
}

// ---- Event ----

abstract class CheckAlarmPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends CheckAlarmPageEvent {}

// ---- State ----

abstract class CheckAlarmPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends CheckAlarmPageState {}

class DataFetching extends CheckAlarmPageState {}

class DataReady extends CheckAlarmPageState {
  final CheckAlarmPageModel info;

  DataReady(this.info);
}

class FetchDataFailed extends CheckAlarmPageState {
  final Object error;

  FetchDataFailed(this.error);
}

const _params = {
  Param.isAlarmOutput,
  Param.isPressTxdrMalf,
  Param.isPressHigh,
  Param.isPressLow,
  Param.pressHighLimit,
  Param.pressLowLimit,
  Param.pressTxdrMalfDate,
  Param.pressTxdrMalfTime,
  Param.isTempTxdrMalf,
  Param.isTempHigh,
  Param.isTempLow,
  Param.tempHighLimit,
  Param.tempLowLimit,
  Param.tempTxdrMalfDate,
  Param.tempTxdrMalfTime,
  Param.isBatteryMalf,
  Param.batteryMalfDate,
  Param.batteryMalfTime,
  Param.isMemoryError,
  Param.memoryErrorDate,
  Param.memoryErrorTime,
  Param.uncVolSinceMalf,
  Param.isUncFlowRateHigh,
  Param.isUncFlowRateLow,
  Param.uncFlowRate,
  Param.uncFlowRateHighLimit,
  Param.uncFlowRateLowLimit,
};
