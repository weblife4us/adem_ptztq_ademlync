import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import '../../utils/functions.dart';
import 'check_q_monitor_group_page_model.dart';

class CheckQMonitorGroupPageBloc
    extends Bloc<CheckQMonitorGroupPageEvent, CheckQMonitorGroupPageState>
    with AdemActionHelper {
  CheckQMonitorGroupPageBloc() : super(NotReady()) {
    on<InfoFetch>(_onInfoFetch);
  }

  Future<void> _onInfoFetch(
    InfoFetch event,
    Emitter<CheckQMonitorGroupPageState> emit,
  ) async {
    emit(InfoFetching());

    final manager = ParamFormatManager();

    try {
      final map = await fetchForParameters(_paramsForFetch);

      if (isCancelCommunication) throw CancelAdemCommunication();

      final info = CheckQMonitorGroupPageModel(
        manager.autoDecode(Param.qMonitorFunction, map),
        manager.autoDecode(Param.diffPress, map),
        manager.autoDecode(Param.minAllowFlowRate, map),
        manager.autoDecode(Param.dpSensorSn, map),
        manager.autoDecode(Param.dpSensorRange, map),
        manager.autoDecode(Param.lineGaugePress, map),
        manager.autoDecode(Param.atmosphericPress, map),
        manager.autoDecode(Param.dpTestPressure, map),
        manager.autoDecode(Param.gasSpecificGravity, map),
        manager.autoDecode(Param.isDpTxdrMalf, map),
        manager.autoDecode(Param.dpTxdrMalfDate, map),
        manager.autoDecode(Param.dpTxdrMalfTime, map),
        manager.autoDecode(Param.qCutoffTempLow, map),
        manager.autoDecode(Param.qCutoffTempHigh, map),
        manager.autoDecode(Param.qCoefficientA, map),
        manager.autoDecode(Param.qCoefficientC, map),
        manager.autoDecode(Param.diffUncertainty, map),
        manager.autoDecode(Param.qSafetyMultiplier, map),
      );

      emit(InfoFetched(info));
    } catch (e) {
      emit(Failure(e));
    }
  }
}

// MARK: - Event

sealed class CheckQMonitorGroupPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class InfoFetch extends CheckQMonitorGroupPageEvent {}

// MARK: - State

sealed class CheckQMonitorGroupPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class NotReady extends CheckQMonitorGroupPageState {}

final class InfoFetching extends CheckQMonitorGroupPageState {}

final class InfoFetched extends CheckQMonitorGroupPageState {
  final CheckQMonitorGroupPageModel info;

  InfoFetched(this.info);
}

final class Failure extends CheckQMonitorGroupPageState {
  final Object error;

  Failure(this.error);
}

const _paramsForFetch = [
  Param.qMonitorFunction,
  Param.diffPress,
  Param.minAllowFlowRate,
  Param.dpSensorSn,
  Param.dpSensorRange,
  Param.lineGaugePress,
  Param.atmosphericPress,
  Param.dpTestPressure,
  Param.gasSpecificGravity,
  Param.isDpTxdrMalf,
  Param.dpTxdrMalfDate,
  Param.dpTxdrMalfTime,
  Param.qCutoffTempLow,
  Param.qCutoffTempHigh,
  Param.qCoefficientA,
  Param.qCoefficientC,
  Param.diffUncertainty,
  Param.qSafetyMultiplier,
];
