import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import 'check_battery_page_model.dart';
import '../../utils/functions.dart';

class CheckBatteryPageBloc
    extends Bloc<CheckBatteryPageEvent, CheckBatteryPageState>
    with AdemActionHelper {
  CheckBatteryPageBloc() : super(DataNotReady()) {
    on<FetchData>(_onFetchData);
  }

  Future<void> _onFetchData(
    FetchData event,
    Emitter<CheckBatteryPageState> emit,
  ) async {
    emit(DataFetching());

    final manager = ParamFormatManager();

    try {
      final map = await fetchForParameters([..._params]);

      if (isCancelCommunication) throw CancelAdemCommunication();

      final info = CheckBatteryPageModel(
        manager.autoDecode(Param.batteryVoltage, map),
        manager.autoDecode(Param.batteryType, map),
        manager.autoDecode(Param.batteryInstallDate, map),
        manager.autoDecode(Param.batteryLife, map),
        manager.autoDecode(Param.batteryRemaining, map),
        manager.autoDecode(Param.displayTestPattern, map),
        manager.autoDecode(Param.pressDispRes, map),
        manager.autoDecode(Param.outPulseSpacing, map),
        manager.autoDecode(Param.outPulseWidth, map),
        manager.autoDecode(Param.corOutputPulseVolUnit, map),
        manager.autoDecode(Param.uncOutputPulseVolUnit, map),
      );

      emit(DataReady(info));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }
}

// ---- Event ----

abstract class CheckBatteryPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends CheckBatteryPageEvent {}

// ---- State ----

abstract class CheckBatteryPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends CheckBatteryPageState {}

class DataFetching extends CheckBatteryPageState {}

class DataReady extends CheckBatteryPageState {
  final CheckBatteryPageModel info;

  DataReady(this.info);
}

class FetchDataFailed extends CheckBatteryPageState {
  final Object error;

  FetchDataFailed(this.error);
}

const _params = {
  Param.batteryVoltage,
  Param.batteryType,
  Param.batteryInstallDate,
  Param.batteryLife,
  Param.batteryRemaining,
  Param.displayTestPattern,
  Param.pressDispRes,
  Param.outPulseSpacing,
  Param.outPulseWidth,
  Param.corOutputPulseVolUnit,
  Param.uncOutputPulseVolUnit,
};
