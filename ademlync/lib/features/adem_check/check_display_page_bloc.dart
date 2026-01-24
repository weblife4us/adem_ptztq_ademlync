import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import 'check_display_page_model.dart';
import '../../utils/app_delegate.dart';
import '../../utils/functions.dart';

class CheckDisplayPageBloc
    extends Bloc<CheckDisplayPageEvent, CheckDisplayPageState>
    with AdemActionHelper {
  CheckDisplayPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Adem get _adem => AppDelegate().adem;

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<CheckDisplayPageState> emit,
  ) async {
    emit(DataFetching());

    final manager = ParamFormatManager();

    try {
      final isAdem25 = AppDelegate().adem.isAdem25;
      final map = await fetchForParameters(_param(isAdem25).toList());

      if (isCancelCommunication) throw CancelAdemCommunication();

      final isProvingPulsesEnabled =
          manager.autoDecode(Param.pushBtnProvingPulsesOpFunc, map) as bool?;

      AppDelegate().cachePushButtonModule(
        _adem.pushButtonModule.copyWith(
          isProvingPulsesEnabled: isProvingPulsesEnabled,
        ),
      );

      final info = CheckDisplayPageModel(
        manager.autoDecode(Param.intervalLogInterval, map),
        manager.autoDecode(Param.intervalLogType, map),
        _customDisplayParams
            .map((o) => manager.autoDecode(o, map))
            .whereType<CustDispItem?>()
            .toList(),
        _adem.measureCache.intervalFields,
        _channelParams
            .map((o) => manager.autoDecode(o, map))
            .whereType<PulseChannel?>()
            .toList(),
        manager.autoDecode(Param.displacement, map),
        manager.autoDecode(Param.pushBtnProvingPulsesOpFunc, map),
        manager.autoDecode(Param.provingTimeout, map),
        isAdem25 ? manager.autoDecode(Param.productType, map) : null,
      );

      emit(DataReady(info));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }
}

// ---- Event ----

abstract class CheckDisplayPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends CheckDisplayPageEvent {}

// ---- State ----

abstract class CheckDisplayPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends CheckDisplayPageState {}

class DataFetching extends CheckDisplayPageState {}

class DataReady extends CheckDisplayPageState {
  final CheckDisplayPageModel info;

  DataReady(this.info);
}

class FetchDataFailed extends CheckDisplayPageState {
  final Object error;

  FetchDataFailed(this.error);
}

Set<Param> _param(bool isAdem25) => {
  Param.intervalLogInterval,
  Param.intervalLogType,
  ..._customDisplayParams,
  ..._channelParams,
  Param.displacement,
  Param.pushBtnProvingPulsesOpFunc,
  Param.provingTimeout,
  if (isAdem25) Param.productType,
};

const _channelParams = {
  Param.outputPulseChannel1,
  Param.outputPulseChannel2,
  Param.outputPulseChannel3,
};

const _customDisplayParams = {
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
};
