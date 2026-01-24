import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import 'setup_display_page_model.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/value_tracker.dart';

class SetupDisplayPageBloc
    extends Bloc<SetupDisplayPageEvent, SetupDisplayPageState>
    with AdemActionHelper {
  SetupDisplayPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
    on<UpdateData>(_mapUpdateDataToState);
  }

  Adem get _adem => AppDelegate().adem;

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<SetupDisplayPageState> emit,
  ) async {
    emit(DataFetching());

    final manager = ParamFormatManager();

    try {
      Adem adem = AppDelegate().adem;

      final isAdem25 = AppDelegate().adem.isAdem25;
      final map = await fetchForParameters(_params(isAdem25).toList());

      if (isCancelCommunication) throw CancelAdemCommunication();

      final intervalType = manager.autoDecode(Param.intervalLogType, map);
      final intervalFields = _intervalLogField
          .map((o) => manager.autoDecode(o, map))
          .whereType<IntervalLogField?>()
          .toList();
      final isProvingPulsesEnabled =
          manager.autoDecode(Param.pushBtnProvingPulsesOpFunc, map) as bool?;

      if (isAdem25) {
        adem = _adem.copyWith(
          productType: manager.autoDecode(Param.productType, map),
        );
        AppDelegate().updateAdem(adem);
      }

      AppDelegate()
        ..cacheMeasure(
          _adem.measureCache.copyWith(
            intervalType: intervalType,
            intervalFields: intervalFields,
          ),
        )
        ..cachePushButtonModule(
          _adem.pushButtonModule.copyWith(
            isProvingPulsesEnabled: isProvingPulsesEnabled,
          ),
        );

      // Map out the page model
      final info = SetupDisplayPageModel(
        buildValueTracker(manager.autoDecode(Param.intervalLogInterval, map)),
        buildValueTracker(intervalType),
        _cstmDispParams
            .map((o) => manager.autoDecode(o, map))
            .whereType<CustDispItem?>()
            .map((o) => buildValueTracker(o))
            .toList(),
        intervalFields.map((o) => buildValueTracker(o)).toList(),
        buildValueTracker(manager.autoDecode(Param.outputPulseChannel3, map)),
        buildValueTracker(isProvingPulsesEnabled),
        buildValueTracker(manager.autoDecode(Param.provingTimeout, map)),
        isAdem25 ? adem.productType : null,
        isAdem25 && (adem.type.isAdemR || adem.type.isAdemMi)
            ? buildValueTracker(adem.type.isAdemR)
            : null,
        buildValueTracker(manager.autoDecode(Param.displacement, map)),
      );

      emit(DataReady(info));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }

  Future<void> _mapUpdateDataToState(
    UpdateData event,
    Emitter<SetupDisplayPageState> emit,
  ) async {
    emit(DataUpdating());

    final user = AppDelegate().user;
    final info = event.info;

    try {
      if (user == null) throw NullSafety.user.exception;

      final tasks = {
        if (info.intervalLogInterval?.isEdited ?? false)
          Param.intervalLogInterval: info.intervalLogInterval!.value.sendKey,
        if (info.intervalLogType?.isEdited ?? false)
          Param.intervalLogType: info.intervalLogType!.value.sendKey,
        if (info.intervalLogType?.value == IntervalLogType.selectableFields)
          for (var i = 0; i < _intervalLogField.length; i++)
            if (info.intervalLogField[i]?.isEdited ?? false)
              _intervalLogField[i]: info.intervalLogField[i]!.value.sendKey,
        for (var i = 0; i < _cstmDispParams.length; i++)
          if (info.cstmDispParams[i]?.isEdited ?? false)
            _cstmDispParams[i]: info.cstmDispParams[i]!.value.sendKey
                .toAdemStringFmt(),
        if (info.pulseChannel3?.isEdited ?? false)
          Param.outputPulseChannel3: info.pulseChannel3!.value.sendKey,
        if (info.isProvingPulsesEnabled case ValueTracker<bool> tracker
            when tracker.isEdited)
          Param.pushBtnProvingPulsesOpFunc: tracker.value
              ? '00000001'
              : '00000000',
        if (info.provingTimeout case ValueTracker<int> tracker
            when tracker.isEdited && _adem.isAdem25)
          Param.provingTimeout: tracker.value.toAdemStringFmt(),
        if (info.isAdemR case ValueTracker<bool> tracker
            when tracker.isEdited && _adem.isAdem25)
          Param.productType: (tracker.value ? 2 : 3).toAdemStringFmt(),
        if (info.displacement?.isEdited ?? false)
          Param.displacement: info.displacement!.value.toAdemStringFmt(
            decimal: Param.displacement.decimal(_adem),
          ),
      };

      await executeTasks(
        [
          for (var o in tasks.entries)
            () => AdemManager().write(o.key.key, o.value),
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

abstract class SetupDisplayPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends SetupDisplayPageEvent {}

class UpdateData extends SetupDisplayPageEvent {
  final String accessCode;
  final SetupDisplayPageModel info;

  UpdateData(this.accessCode, this.info);
}

// ---- State ----

abstract class SetupDisplayPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends SetupDisplayPageState {}

class DataFetching extends SetupDisplayPageState {}

class DataUpdating extends SetupDisplayPageState {}

class DataReady extends SetupDisplayPageState {
  final SetupDisplayPageModel info;

  DataReady(this.info);
}

class DataUpdated extends SetupDisplayPageState {}

class FetchDataFailed extends SetupDisplayPageState {
  final Object error;

  FetchDataFailed(this.error);
}

class UpdateDataFailed extends SetupDisplayPageState {
  final Object error;

  UpdateDataFailed(this.error);
}

Set<Param> _params(bool isAdem25) => {
  Param.intervalLogInterval,
  Param.intervalLogType,
  ..._intervalLogField,
  ..._cstmDispParams,
  Param.outputPulseChannel3,
  Param.pushBtnProvingPulsesOpFunc,
  Param.provingTimeout,
  if (isAdem25) Param.productType,
  Param.displacement,
};

final _intervalLogField = [
  Param.intervalField5,
  Param.intervalField6,
  Param.intervalField7,
  Param.intervalField8,
  Param.intervalField9,
  Param.intervalField10,
];

final _cstmDispParams = [
  Param.cstmDispParam1,
  Param.cstmDispParam2,
  Param.cstmDispParam3,
  Param.cstmDispParam4,
  Param.cstmDispParam5,
  Param.cstmDispParam6,
  Param.cstmDispParam7,
  Param.cstmDispParam8,
  Param.cstmDispParam9,
  Param.cstmDispParam10,
  Param.cstmDispParam11,
  Param.cstmDispParam12,
  Param.cstmDispParam13,
  Param.cstmDispParam14,
  Param.cstmDispParam15,
];
