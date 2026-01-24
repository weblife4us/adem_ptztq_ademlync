import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import 'check_factor_page_model.dart';
import '../../utils/functions.dart';

class CheckFactorPageBloc
    extends Bloc<CheckFactorPageEvent, CheckFactorPageState>
    with AdemActionHelper {
  CheckFactorPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<CheckFactorPageState> emit,
  ) async {
    emit(DataFetching());

    final manager = ParamFormatManager();

    try {
      final map = await fetchForParameters([..._params]);

      if (isCancelCommunication) throw CancelAdemCommunication();

      final superXFactorType = manager.autoDecode(Param.superXFactorType, map);

      final info = CheckFactorPageModel(
        manager.autoDecode(Param.superXAlgo, map),
        manager.autoDecode(Param.gasSpecificGravity, map),
        manager.autoDecode(Param.gasMoleCO2, map),
        manager.autoDecode(Param.gasMoleH2, map),
        manager.autoDecode(Param.gasMoleN2, map),
        manager.autoDecode(Param.gasMoleHs, map),
        manager.autoDecode(Param.pressFactorType, map),
        manager.autoDecode(Param.tempFactorType, map),
        manager.autoDecode(Param.superXFactorType, map),
        manager.autoDecode(Param.pressFactor, map),
        manager.autoDecode(Param.tempFactor, map),
        superXFactorType == null
            ? null
            : superXFactorType == FactorType.live
            ? manager.autoDecode(Param.liveSuperXFactor, map)
            : manager.autoDecode(Param.fixedSuperXFactor, map),
        manager.autoDecode(Param.totalFactor, map),
        manager.autoDecode(Param.baseTemp, map),
        manager.autoDecode(Param.basePress, map),
        manager.autoDecode(Param.atmosphericPress, map),
        manager.autoDecode(Param.dispVolSelect, map),
      );

      emit(DataReady(info));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }
}

// ---- Event ----

abstract class CheckFactorPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends CheckFactorPageEvent {}

// ---- State ----

abstract class CheckFactorPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends CheckFactorPageState {}

class DataFetching extends CheckFactorPageState {}

class DataReady extends CheckFactorPageState {
  final CheckFactorPageModel info;

  DataReady(this.info);
}

class FetchDataFailed extends CheckFactorPageState {
  final Object error;

  FetchDataFailed(this.error);
}

const _params = {
  Param.superXAlgo,
  Param.gasSpecificGravity,
  Param.gasMoleCO2,
  Param.gasMoleH2,
  Param.gasMoleN2,
  Param.gasMoleHs,
  Param.pressFactorType,
  Param.tempFactorType,
  Param.superXFactorType,
  Param.liveSuperXFactor,
  Param.fixedSuperXFactor,
  Param.pressFactor,
  Param.tempFactor,
  Param.totalFactor,
  Param.baseTemp,
  Param.basePress,
  Param.atmosphericPress,
  Param.dispVolSelect,
};
