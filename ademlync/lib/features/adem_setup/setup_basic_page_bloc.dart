import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'setup_basic_page_model.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/value_tracker.dart';

class SetupBasicPageBloc extends Bloc<SetupBasicPageEvent, SetupBasicPageState>
    with AdemActionHelper {
  SetupBasicPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
    on<UpdateData>(_mapUpdateDataToState);
  }

  Adem get _adem => AppDelegate().adem;

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<SetupBasicPageState> emit,
  ) async {
    emit(DataFetching());

    try {
      // Fetch params
      final map = await fetchForParameters([
        ..._params(AppDelegate().adem.type),
      ]);

      if (isCancelCommunication) throw CancelAdemCommunication();

      // Update the AdEM cache
      AppDelegate()
        ..cacheConfig(
          _adem.configCache.copyWith(
            gasDayStartTime: DataParser.asTime(map[Param.gasDayStartTime]),
          ),
        )
        ..cacheMeasure(
          _adem.measureCache.copyWith(
            meterSize: MeterSize.from(map[Param.meterSize]?.body),
            uncVolUnit: VolumeUnit.from(map[Param.uncVolUnit]?.body),
            corVolUnit: VolumeUnit.from(map[Param.corVolUnit]?.body),
            uncVolDigits: VolDigits.from(map[Param.uncVolDigits]?.body),
            corVolDigits: VolDigits.from(map[Param.corVolDigits]?.body),
            dispVolSelect: DispVolSelect.from(map[Param.dispVolSelect]?.body),
            inputPulseVolUnit: InputPulseVolumeUnit.from(
              map[Param.inputPulseVolUnit]?.body,
            ),
            uncOutputPulseVolUnit: VolumeUnit.from(
              map[Param.uncOutputPulseVolUnit]?.body,
            ),
            corOutputPulseVolUnit: VolumeUnit.from(
              map[Param.corOutputPulseVolUnit]?.body,
            ),
            pressUnit: PressUnit.from(map[Param.pressUnit]?.body),
            tempUnit: TempUnit.from(map[Param.tempUnit]?.body),
          ),
        );

      // Update the AdEM cache for AdEM Tq
      if (_adem.type == AdemType.ademTq) {
        AppDelegate().cacheMeasure(
          _adem.measureCache.copyWith(
            differentialPressureUnit: _adem.meterSystem.toDiffPressUnit,
            lineGaugePressureUnit: _adem.meterSystem.toLineGaugePressUnit,
          ),
        );
      }

      final type = _adem.volumeType;

      // Map out the page model
      final info = SetupBasicPageModel(
        buildValueTracker(_adem.configCache.gasDayStartTime),
        buildValueTracker(_adem.measureCache.dispVolSelect),
        buildValueTracker(_adem.meterSize),
        buildValueTracker(_adem.meterSize?.serial),
        buildValueTracker(_adem.meterSize?.serial.system),
        buildValueTracker(DataParser.asInt(map[Param.corVol])),
        type.volumeMultiplier(DataParser.asNum(map[Param.corFullVol])),
        buildValueTracker(_adem.measureCache.corVolUnit),
        buildValueTracker(_adem.measureCache.corVolDigits),
        buildValueTracker(DataParser.asInt(map[Param.uncVol])),
        type.volumeMultiplier(DataParser.asNum(map[Param.uncFullVol])),
        buildValueTracker(_adem.measureCache.uncVolUnit),
        buildValueTracker(_adem.measureCache.uncVolDigits),
        buildValueTracker(_adem.inputPulseVolUnit),
        buildValueTracker(
          OutPulseSpacing.from(map[Param.outPulseSpacing]?.body),
        ),
        buildValueTracker(OutPulseWidth.from(map[Param.outPulseWidth]?.body)),
        buildValueTracker(_adem.measureCache.corOutputPulseVolUnit),
        buildValueTracker(_adem.measureCache.uncOutputPulseVolUnit),
        buildValueTracker(_adem.measureCache.pressUnit),
        _adem.measureCache.tempUnit,
      );

      emit(DataReady(info));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }

  Future<void> _mapUpdateDataToState(
    UpdateData event,
    Emitter<SetupBasicPageState> emit,
  ) async {
    emit(DataUpdating());

    final user = AppDelegate().user;
    final info = event.info;

    try {
      if (user == null) throw NullSafety.user.exception;

      final adem = AppDelegate().adem;

      // Map out the AdEM receive format
      final tasks = {
        if (info.gasDayStartTime?.isEdited ?? false)
          Param.gasDayStartTime: unitTimeFmt.format(
            info.gasDayStartTime!.value,
          ),
        if (info.dispVolSelect?.isEdited ?? false)
          Param.dispVolSelect: info.dispVolSelect!.value.sendKey,
        if (info.meterSize?.isEdited ?? false)
          Param.meterSize: info.meterSize!.value.sendKey,
        if (info.corVolUnit?.isEdited ?? false)
          Param.corVolUnit: info.corVolUnit!.value.sendKey,
        if (info.corVolDigits?.isEdited ?? false)
          Param.corVolDigits: info.corVolDigits!.value.sendKey,
        if (info.uncVolUnit?.isEdited ?? false)
          Param.uncVolUnit: info.uncVolUnit!.value.sendKey,
        if (info.uncVolDigits?.isEdited ?? false)
          Param.uncVolDigits: info.uncVolDigits!.value.sendKey,
        if (info.corOutputPulseVolUnit?.isEdited ?? false)
          Param.corOutputPulseVolUnit:
              info.corOutputPulseVolUnit!.value.sendKey,
        if (info.uncOutputPulseVolUnit?.isEdited ?? false)
          Param.uncOutputPulseVolUnit:
              info.uncOutputPulseVolUnit!.value.sendKey,
        if (info.corVol?.isEdited ?? false)
          Param.corVol: info.corVol!.value.toAdemStringFmt(
            decimal: Param.corVol.decimal(adem),
          ),
        if (info.uncVol?.isEdited ?? false)
          Param.uncVol: info.uncVol!.value.toAdemStringFmt(
            decimal: Param.uncVol.decimal(adem),
          ),
        if (info.outPulseSpacing?.isEdited ?? false)
          Param.outPulseSpacing: info.outPulseSpacing!.value.sendKey,
        if (info.outPulseWidth?.isEdited ?? false)
          Param.outPulseWidth: info.outPulseWidth!.value.sendKey,
        if (info.inputPulseVolUnit?.isEdited ?? false)
          Param.inputPulseVolUnit: info.inputPulseVolUnit!.value.sendKey,
        if (info.pressUnit case final unit? when unit.isEdited)
          Param.pressUnit: unit.value.sendKey,
      };

      // Sent to AdEM
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

abstract class SetupBasicPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends SetupBasicPageEvent {}

class UpdateData extends SetupBasicPageEvent {
  final String accessCode;
  final SetupBasicPageModel info;

  UpdateData(this.accessCode, this.info);
}

// ---- State ----

abstract class SetupBasicPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends SetupBasicPageState {}

class DataFetching extends SetupBasicPageState {}

class DataUpdating extends SetupBasicPageState {}

class DataReady extends SetupBasicPageState {
  final SetupBasicPageModel info;

  DataReady(this.info);
}

class DataUpdated extends SetupBasicPageState {}

class FetchDataFailed extends SetupBasicPageState {
  final Object error;

  FetchDataFailed(this.error);
}

class UpdateDataFailed extends SetupBasicPageState {
  final Object error;

  UpdateDataFailed(this.error);
}

Set<Param> _params(AdemType type) => {
  Param.gasDayStartTime,
  Param.dispVolSelect,
  Param.meterSize,
  Param.corVol,
  Param.corFullVol,
  Param.corVolUnit,
  Param.corVolDigits,
  Param.uncVol,
  Param.uncFullVol,
  Param.uncVolUnit,
  Param.uncVolDigits,
  Param.inputPulseVolUnit,
  Param.outPulseSpacing,
  Param.outPulseWidth,
  Param.corOutputPulseVolUnit,
  Param.uncOutputPulseVolUnit,
  Param.provingVol,
  Param.pressUnit,
  Param.tempUnit,
};
