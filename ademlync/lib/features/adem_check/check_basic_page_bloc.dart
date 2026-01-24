import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import 'check_basic_page_model.dart';
import '../../utils/app_delegate.dart';
import '../../utils/functions.dart';

class CheckBasicPageBloc extends Bloc<CheckBasicPageEvent, CheckBasicPageState>
    with AdemActionHelper {
  CheckBasicPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Adem get _adem => AppDelegate().adem;
  VolumeType get _volume => _adem.volumeType;

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<CheckBasicPageState> emit,
  ) async {
    emit(DataFetching());

    final manager = ParamFormatManager();

    try {
      final type = AppDelegate().adem.type;
      final map = await fetchForParameters(_params(type).toList());

      if (isCancelCommunication) throw CancelAdemCommunication();

      final info = CheckBasicPageModel(
        manager.autoDecode(Param.firmwareVersion, map),
        manager.autoDecode(Param.firmwareChecksum, map),
        manager.autoDecode(Param.sealStatus, map),
        manager.autoDecode(Param.gasDayStartTime, map),
        manager.autoDecode(Param.meterSize, map),
        manager.autoDecode(Param.inputPulseVolUnit, map),
        manager.autoDecode(Param.corVol, map),
        _volume.volumeMultiplier(manager.autoDecode(Param.corFullVol, map)),
        _volume.highResVolMultiplier(
          manager.autoDecode(Param.corHighResVol, map),
        ),
        manager.autoDecode(Param.corDailyVol, map),
        manager.autoDecode(Param.corPrevDayVol, map),
        manager.autoDecode(Param.uncVol, map),
        _volume.volumeMultiplier(manager.autoDecode(Param.uncFullVol, map)),
        _volume.highResVolMultiplier(
          manager.autoDecode(Param.uncHighResVol, map),
        ),
        manager.autoDecode(Param.uncDailyVol, map),
        manager.autoDecode(Param.uncPrevDayVol, map),
        type.isAdemTq ? null : manager.autoDecode(Param.pressTransType, map),
        type.isAdemTq ? null : manager.autoDecode(Param.pressTransSn, map),
        type.isAdemTq ? null : manager.autoDecode(Param.pressTransRange, map),
        type.isAdemTq ? null : manager.autoDecode(Param.absPress, map),
        type.isAdemTq ? null : manager.autoDecode(Param.gaugePress, map),
        manager.autoDecode(Param.temp, map),
        manager.autoDecode(Param.caseTemp, map),
        manager.autoDecode(Param.corFlowRate, map),
        manager.autoDecode(Param.uncFlowRate, map),
        manager.autoDecode(Param.pressUnit, map),
        manager.autoDecode(Param.tempUnit, map),
        manager.autoDecode(Param.corVolUnit, map),
        manager.autoDecode(Param.uncVolUnit, map),
        manager.autoDecode(Param.corVolDigits, map),
        manager.autoDecode(Param.uncVolDigits, map),
      );

      emit(DataReady(info));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }
}

// ---- Event ----

abstract class CheckBasicPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends CheckBasicPageEvent {}

// ---- State ----

abstract class CheckBasicPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends CheckBasicPageState {}

class DataFetching extends CheckBasicPageState {}

class DataReady extends CheckBasicPageState {
  final CheckBasicPageModel info;

  DataReady(this.info);
}

class FetchDataFailed extends CheckBasicPageState {
  final Object error;

  FetchDataFailed(this.error);
}

Set<Param> _params(AdemType type) => {
  Param.firmwareVersion,
  Param.firmwareChecksum,
  Param.sealStatus,
  Param.gasDayStartTime,
  Param.meterSize,
  Param.inputPulseVolUnit,
  Param.corVol,
  Param.corFullVol,
  Param.corHighResVol,
  Param.corDailyVol,
  Param.corPrevDayVol,
  Param.uncVol,
  Param.uncFullVol,
  Param.uncHighResVol,
  Param.uncDailyVol,
  Param.uncPrevDayVol,
  if (!type.isAdemTq) Param.pressTransType,
  if (!type.isAdemTq) Param.pressTransSn,
  if (!type.isAdemTq) Param.pressTransRange,
  if (!type.isAdemTq) Param.absPress,
  if (!type.isAdemTq) Param.gaugePress,
  Param.temp,
  Param.caseTemp,
  Param.corFlowRate,
  Param.uncFlowRate,
  Param.pressUnit,
  Param.tempUnit,
  Param.corVolUnit,
  Param.uncVolUnit,
  Param.corVolDigits,
  Param.uncVolDigits,
};
