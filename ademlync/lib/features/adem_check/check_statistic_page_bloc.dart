import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import 'check_statistic_page_model.dart';
import '../../utils/functions.dart';

class CheckStatisticPageBloc
    extends Bloc<CheckStatisticPageEvent, CheckStatisticPageState>
    with AdemActionHelper {
  CheckStatisticPageModel? info;

  CheckStatisticPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<CheckStatisticPageState> emit,
  ) async {
    emit(DataFetching());

    final manager = ParamFormatManager();

    try {
      final map = await fetchForParameters([..._params]);

      if (isCancelCommunication) throw CancelAdemCommunication();

      // NOTE: #831 and #879 are pointing to the same param
      final ucIndexRollover = map.containsKey(Param.uncorrectedIndexRollover)
          ? manager.autoDecode(Param.uncorrectedIndexRollover, map) as int?
          : map.containsKey(Param.legacyUncorrectedIndexRollover)
          ? manager.autoDecode(Param.legacyUncorrectedIndexRollover, map)
                as int?
          : null;

      // NOTE: #832 and #880 are pointing to the same param
      final ccIndexRollover = map.containsKey(Param.correctedIndexRollover)
          ? manager.autoDecode(Param.correctedIndexRollover, map) as int?
          : map.containsKey(Param.legacyCorrectedIndexRollover)
          ? manager.autoDecode(Param.legacyCorrectedIndexRollover, map) as int?
          : null;

      final info = CheckStatisticPageModel(
        manager.autoDecode(Param.maxPress, map),
        manager.autoDecode(Param.maxPressDate, map),
        manager.autoDecode(Param.maxPressTime, map),
        manager.autoDecode(Param.minPress, map),
        manager.autoDecode(Param.minPressDate, map),
        manager.autoDecode(Param.minPressTime, map),
        manager.autoDecode(Param.maxTemp, map),
        manager.autoDecode(Param.maxTempDate, map),
        manager.autoDecode(Param.maxTempTime, map),
        manager.autoDecode(Param.minTemp, map),
        manager.autoDecode(Param.minTempDate, map),
        manager.autoDecode(Param.minTempTime, map),
        manager.autoDecode(Param.maxCaseTemp, map),
        manager.autoDecode(Param.minCaseTemp, map),
        manager.autoDecode(Param.uncPeakFlowRate, map),
        manager.autoDecode(Param.uncPeakFlowRateDate, map),
        manager.autoDecode(Param.uncPeakFlowRateTime, map),
        manager.autoDecode(Param.corLastSavedVol, map),
        manager.autoDecode(Param.uncLastSavedVol, map),
        manager.autoDecode(Param.lastSaveDate, map),
        manager.autoDecode(Param.lastSaveTime, map),
        manager.autoDecode(Param.backupIndexCounter, map),
        ucIndexRollover != null ? ucIndexRollover == 1 : null,
        ccIndexRollover != null ? ccIndexRollover == 1 : null,
        manager.autoDecode(Param.showDot, map),
      );

      emit(DataReady(info));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }
}

// ---- Event ----

abstract class CheckStatisticPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends CheckStatisticPageEvent {}

// ---- State ----

abstract class CheckStatisticPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends CheckStatisticPageState {}

class DataFetching extends CheckStatisticPageState {}

class DataReady extends CheckStatisticPageState {
  final CheckStatisticPageModel info;

  DataReady(this.info);
}

class FetchDataFailed extends CheckStatisticPageState {
  final Object error;
  FetchDataFailed(this.error);
}

const _params = {
  Param.maxPress,
  Param.maxPressDate,
  Param.maxPressTime,
  Param.minPress,
  Param.minPressDate,
  Param.minPressTime,
  Param.maxTemp,
  Param.maxTempDate,
  Param.maxTempTime,
  Param.minTemp,
  Param.minTempDate,
  Param.minTempTime,
  Param.maxCaseTemp,
  Param.minCaseTemp,
  Param.uncPeakFlowRate,
  Param.uncPeakFlowRateDate,
  Param.uncPeakFlowRateTime,
  Param.corLastSavedVol,
  Param.uncLastSavedVol,
  Param.lastSaveDate,
  Param.lastSaveTime,
  Param.backupIndexCounter,
  Param.legacyUncorrectedIndexRollover,
  Param.legacyCorrectedIndexRollover,
  Param.uncorrectedIndexRollover,
  Param.correctedIndexRollover,
  Param.showDot,
};
