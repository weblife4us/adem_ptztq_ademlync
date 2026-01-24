import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import 'setup_q_monitor_group_page_model.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/value_tracker.dart';

class SetupQMonitorGroupPageBloc
    extends Bloc<SetupQMonitorGroupPageEvent, SetupQMonitorGroupPageState>
    with AdemActionHelper {
  SetupQMonitorGroupPageBloc() : super(SQMGPBNotReadyState()) {
    on<SQMGPBFetchEvent>(_mapSQMGPBFetchEventToState);
    on<SQMGPBUpdateEvent>(_mapSQMGPBUpdateEventToState);
  }

  Future<void> _mapSQMGPBFetchEventToState(
    SQMGPBFetchEvent event,
    Emitter<SetupQMonitorGroupPageState> emit,
  ) async {
    emit(SQMGPBFetchingState());

    final manager = ParamFormatManager();

    try {
      final map = await fetchForParameters(_paramsForFetch);

      if (isCancelCommunication) throw CancelAdemCommunication();

      final info = SetupQMonitorGroupPageModel(
        manager.autoDecode(Param.qMonitorFunction, map),
        manager.autoDecode(Param.diffPress, map),
        manager.autoDecode(Param.minAllowFlowRate, map),
        manager.autoDecode(Param.dpSensorSn, map),
        manager.autoDecode(Param.dpSensorRange, map),
        buildValueTracker(manager.autoDecode(Param.lineGaugePress, map)),
        buildValueTracker(manager.autoDecode(Param.atmosphericPress, map)),
        manager.autoDecode(Param.dpTestPressure, map),
        buildValueTracker(manager.autoDecode(Param.gasSpecificGravity, map)),
        manager.autoDecode(Param.isDpTxdrMalf, map),
        manager.autoDecode(Param.dpTxdrMalfDate, map),
        manager.autoDecode(Param.dpTxdrMalfTime, map),
        buildValueTracker(manager.autoDecode(Param.qCutoffTempLow, map)),
        buildValueTracker(manager.autoDecode(Param.qCutoffTempHigh, map)),
        manager.autoDecode(Param.qCoefficientA, map),
        manager.autoDecode(Param.qCoefficientC, map),
        buildValueTracker(manager.autoDecode(Param.diffUncertainty, map)),
        manager.autoDecode(Param.qSafetyMultiplier, map),
      );

      emit(SQMGPBReadyState(info));
    } catch (e) {
      emit(SQMGPBFailedState(event, e));
    }
  }

  Future<void> _mapSQMGPBUpdateEventToState(
    SQMGPBUpdateEvent event,
    Emitter<SetupQMonitorGroupPageState> emit,
  ) async {
    emit(SQMGPBUpdatingState());

    final user = AppDelegate().user;
    final info = event.info;

    try {
      if (user == null) throw NullSafety.user.exception;

      final adem = AppDelegate().adem;

      final tasks = {
        if (info.lineGaugePress?.isEdited ?? false)
          Param.lineGaugePress: info.lineGaugePress!.value.toAdemStringFmt(
            decimal: Param.lineGaugePress.decimal(adem),
          ),
        if (info.atmosphericPress?.isEdited ?? false)
          Param.atmosphericPress: info.atmosphericPress!.value.toAdemStringFmt(
            decimal: Param.atmosphericPress.decimal(adem),
            prefix: 'S',
          ),
        if (info.gasSpecificGravity?.isEdited ?? false)
          Param.gasSpecificGravity: info.gasSpecificGravity!.value
              .toAdemStringFmt(decimal: Param.gasSpecificGravity.decimal(adem)),
        if (info.qCutoffTempHigh?.isEdited ?? false)
          Param.qCutoffTempHigh: info.qCutoffTempHigh!.value.toAdemStringFmt(
            decimal: Param.qCutoffTempHigh.decimal(adem),
          ),
        if (info.qCutoffTempLow?.isEdited ?? false)
          Param.qCutoffTempLow: info.qCutoffTempLow!.value.toAdemStringFmt(
            decimal: Param.qCutoffTempLow.decimal(adem),
          ),
        if (info.diffUncertainty?.isEdited ?? false)
          Param.diffUncertainty: info.diffUncertainty!.value.toAdemStringFmt(
            decimal: Param.diffUncertainty.decimal(adem),
          ),
      };

      await executeTasks(
        [
          for (var e in tasks.entries)
            () => AdemManager().write(e.key.key, e.value),
        ],
        accessCode: event.accessCode,
        userId: user.id,
      );

      emit(SQMGPBUpdatedState());
    } catch (e) {
      emit(SQMGPBFailedState(event, e));
    }

    add(SQMGPBFetchEvent());
  }
}

// ---- Event ----

abstract class SetupQMonitorGroupPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class SQMGPBFetchEvent extends SetupQMonitorGroupPageEvent {}

class SQMGPBUpdateEvent extends SetupQMonitorGroupPageEvent {
  final String accessCode;
  final SetupQMonitorGroupPageModel info;

  SQMGPBUpdateEvent(this.accessCode, this.info);
}

// ---- State ----

abstract class SetupQMonitorGroupPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class SQMGPBNotReadyState extends SetupQMonitorGroupPageState {}

class SQMGPBFetchingState extends SetupQMonitorGroupPageState {}

class SQMGPBUpdatingState extends SetupQMonitorGroupPageState {}

class SQMGPBReadyState extends SetupQMonitorGroupPageState {
  final SetupQMonitorGroupPageModel info;

  SQMGPBReadyState(this.info);
}

class SQMGPBUpdatedState extends SetupQMonitorGroupPageState {}

class SQMGPBFailedState extends SetupQMonitorGroupPageState {
  final SetupQMonitorGroupPageEvent event;
  final Object error;

  SQMGPBFailedState(this.event, this.error);
}

// --- Function ---

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
