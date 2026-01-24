import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import 'setup_press_and_temp_page_model.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/value_tracker.dart';

class SetupPressAndTempPageBloc
    extends Bloc<SetupPressAndTempPageEvent, SetupPressAndTempPageState>
    with AdemActionHelper {
  SetupPressAndTempPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
    on<UpdateData>(_mapUpdateDataToState);
  }

  Adem get _adem => AppDelegate().adem;

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<SetupPressAndTempPageState> emit,
  ) async {
    emit(DataFetching());

    final manager = ParamFormatManager();

    try {
      final map = await fetchForParameters([..._params]);

      if (isCancelCommunication) throw CancelAdemCommunication();

      AppDelegate().cacheMeasure(
        _adem.measureCache.copyWith(
          pressTransType: manager.autoDecode(Param.pressTransType, map),
          tempFactorType: manager.autoDecode(Param.tempFactorType, map),
          pressFactorType: manager.autoDecode(Param.pressFactorType, map),
          superXFactorType: manager.autoDecode(Param.superXFactorType, map),
          superXAlgorithm: manager.autoDecode(Param.superXAlgo, map),
          pressUnit: manager.autoDecode(Param.pressUnit, map),
          tempUnit: manager.autoDecode(Param.tempUnit, map),
        ),
      );

      // Map out the page model
      final info = SetupPressAndTempPageModel(
        _adem.measureCache.pressTransType,
        buildValueTracker(manager.autoDecode(Param.pressTransSn, map)),
        buildValueTracker(manager.autoDecode(Param.pressTransRange, map)),
        buildValueTracker(_adem.measureCache.pressFactorType),
        buildValueTracker(manager.autoDecode(Param.pressFactor, map)),
        manager.autoDecode(Param.absPress, map),
        manager.autoDecode(Param.gaugePress, map),
        buildValueTracker(manager.autoDecode(Param.pressHighLimit, map)),
        buildValueTracker(manager.autoDecode(Param.pressLowLimit, map)),
        buildValueTracker(manager.autoDecode(Param.atmosphericPress, map)),
        buildValueTracker(manager.autoDecode(Param.basePress, map)),
        buildValueTracker(_adem.measureCache.tempFactorType),
        buildValueTracker(manager.autoDecode(Param.tempFactor, map)),
        manager.autoDecode(Param.temp, map),
        buildValueTracker(manager.autoDecode(Param.tempHighLimit, map)),
        buildValueTracker(manager.autoDecode(Param.tempLowLimit, map)),
        buildValueTracker(manager.autoDecode(Param.baseTemp, map)),
        buildValueTracker(_adem.measureCache.superXFactorType),
        buildValueTracker(
          manager.autoDecode(
            _adem.measureCache.superXFactorType == FactorType.live
                ? Param.liveSuperXFactor
                : Param.fixedSuperXFactor,
            map,
          ),
        ),
        buildValueTracker(_adem.measureCache.superXAlgorithm),
        buildValueTracker(manager.autoDecode(Param.gasSpecificGravity, map)),
        buildValueTracker(manager.autoDecode(Param.gasMoleN2, map)),
        buildValueTracker(manager.autoDecode(Param.gasMoleH2, map)),
        buildValueTracker(manager.autoDecode(Param.gasMoleCO2, map)),
        buildValueTracker(manager.autoDecode(Param.gasMoleHs, map)),
        buildValueTracker(manager.autoDecode(Param.uncFlowRateHighLimit, map)),
        buildValueTracker(manager.autoDecode(Param.uncFlowRateLowLimit, map)),
      );

      emit(DataReady(info));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }

  Future<void> _mapUpdateDataToState(
    UpdateData event,
    Emitter<SetupPressAndTempPageState> emit,
  ) async {
    emit(DataUpdating());

    final user = AppDelegate().user;
    final info = event.info;

    try {
      if (user == null) throw NullSafety.user.exception;

      final tasks = {
        if (info.pressTxdrSn?.isEdited ?? false)
          Param.pressTransSn: info.pressTxdrSn!.value.toAdemStringFmt(
            decimal: Param.pressTransSn.decimal(_adem),
          ),
        if (info.pressTxdrRange?.isEdited ?? false)
          Param.pressTransRange: info.pressTxdrRange!.value.toAdemStringFmt(
            decimal: Param.pressTransRange.decimal(_adem),
          ),
        if (info.pressHighLimit?.isEdited ?? false)
          Param.pressHighLimit: info.pressHighLimit!.value.toAdemStringFmt(
            decimal: Param.pressHighLimit.decimal(_adem),
          ),
        if (info.pressLowLimit?.isEdited ?? false)
          Param.pressLowLimit: info.pressLowLimit!.value.toAdemStringFmt(
            decimal: Param.pressLowLimit.decimal(_adem),
          ),
        if (info.pressFactorType?.isEdited ?? false)
          Param.pressFactorType: info.pressFactorType!.value.sendKey,
        if (info.tempHighLimit?.isEdited ?? false)
          Param.tempHighLimit: info.tempHighLimit!.value.toAdemStringFmt(
            decimal: Param.tempHighLimit.decimal(_adem),
          ),
        if (info.tempLowLimit?.isEdited ?? false)
          Param.tempLowLimit: info.tempLowLimit!.value.toAdemStringFmt(
            decimal: Param.tempLowLimit.decimal(_adem),
          ),
        if (info.tempFactorType?.isEdited ?? false)
          Param.tempFactorType: info.tempFactorType!.value.sendKey,
        if (info.uncFlowrateHighLimit?.isEdited ?? false)
          Param.uncFlowRateHighLimit: info.uncFlowrateHighLimit!.value
              .toAdemStringFmt(
                decimal: Param.uncFlowRateHighLimit.decimal(_adem),
              ),
        if (info.uncFlowrateLowLimit?.isEdited ?? false)
          Param.uncFlowRateLowLimit: info.uncFlowrateLowLimit!.value
              .toAdemStringFmt(
                decimal: Param.uncFlowRateLowLimit.decimal(_adem),
              ),
        if (info.superXFactorType?.isEdited ?? false)
          Param.superXFactorType: info.superXFactorType!.value.sendKey,
        if (info.superXAlgo?.isEdited ?? false)
          Param.superXAlgo: info.superXAlgo!.value.sendKey,
        if (info.superXFactor?.isEdited ?? false)
          Param.fixedSuperXFactor: info.superXFactor!.value.toAdemStringFmt(
            decimal: Param.fixedSuperXFactor.decimal(_adem),
          ),
        if (info.gasSpecificGravity?.isEdited ?? false)
          Param.gasSpecificGravity: info.gasSpecificGravity!.value
              .toAdemStringFmt(
                decimal: Param.gasSpecificGravity.decimal(_adem),
              ),
        if (info.gasMoleN2?.isEdited ?? false)
          Param.gasMoleN2: info.gasMoleN2!.value.toAdemStringFmt(
            decimal: Param.gasMoleN2.decimal(_adem),
          ),
        if (info.gasMoleH2?.isEdited ?? false)
          Param.gasMoleH2: info.gasMoleH2!.value.toAdemStringFmt(
            decimal: Param.gasMoleH2.decimal(_adem),
          ),
        if (info.gasMoleCO2?.isEdited ?? false)
          Param.gasMoleCO2: info.gasMoleCO2!.value.toAdemStringFmt(
            decimal: Param.gasMoleCO2.decimal(_adem),
          ),
        if (info.gasMoleHs?.isEdited ?? false)
          Param.gasMoleHs: info.gasMoleHs!.value.toAdemStringFmt(
            decimal: Param.gasMoleHs.decimal(_adem),
          ),
        if (info.basePress?.isEdited ?? false)
          Param.basePress: info.basePress!.value.toAdemStringFmt(
            decimal: Param.basePress.decimal(_adem),
            prefix: 'S',
          ),
        if (info.baseTemp?.isEdited ?? false)
          Param.baseTemp: info.baseTemp!.value.toAdemStringFmt(
            decimal: Param.baseTemp.decimal(_adem) + 1,
            prefix: 'S',
          ),
        if (info.atmosphericPress?.isEdited ?? false)
          Param.atmosphericPress: info.atmosphericPress!.value.toAdemStringFmt(
            decimal: Param.atmosphericPress.decimal(_adem),
            prefix: 'S',
          ),
        if (info.pressFactor?.isEdited ?? false)
          Param.pressFactor: info.pressFactor!.value.toAdemStringFmt(
            decimal: Param.pressFactor.decimal(_adem),
          ),
        if (info.tempFactor?.isEdited ?? false)
          Param.tempFactor: info.tempFactor!.value.toAdemStringFmt(
            decimal: Param.tempFactor.decimal(_adem),
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

      emit(DataUpdated());
    } catch (e) {
      emit(UpdateDataFailed(e));
    }

    add(FetchData());
  }
}

// ---- Event ----

abstract class SetupPressAndTempPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends SetupPressAndTempPageEvent {}

class UpdateData extends SetupPressAndTempPageEvent {
  final String accessCode;
  final SetupPressAndTempPageModel info;

  UpdateData(this.accessCode, this.info);
}

// ---- State ----

abstract class SetupPressAndTempPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends SetupPressAndTempPageState {}

class DataFetching extends SetupPressAndTempPageState {}

class DataUpdating extends SetupPressAndTempPageState {}

class DataReady extends SetupPressAndTempPageState {
  final SetupPressAndTempPageModel info;

  DataReady(this.info);
}

class DataUpdated extends SetupPressAndTempPageState {}

class FetchDataFailed extends SetupPressAndTempPageState {
  final Object error;

  FetchDataFailed(this.error);
}

class UpdateDataFailed extends SetupPressAndTempPageState {
  final Object error;

  UpdateDataFailed(this.error);
}

const _params = {
  Param.pressTransType,
  Param.pressFactorType,
  Param.tempFactorType,
  Param.superXFactorType,
  Param.superXAlgo,
  Param.pressTransSn,
  Param.pressTransRange,
  Param.pressFactor,
  Param.absPress,
  Param.gaugePress,
  Param.pressHighLimit,
  Param.pressLowLimit,
  Param.atmosphericPress,
  Param.basePress,
  Param.tempFactor,
  Param.temp,
  Param.tempHighLimit,
  Param.tempLowLimit,
  Param.baseTemp,
  Param.liveSuperXFactor,
  Param.fixedSuperXFactor,
  Param.gasSpecificGravity,
  Param.gasMoleN2,
  Param.gasMoleH2,
  Param.gasMoleCO2,
  Param.gasMoleHs,
  Param.uncFlowRateHighLimit,
  Param.uncFlowRateLowLimit,
};
