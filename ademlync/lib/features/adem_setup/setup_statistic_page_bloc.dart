import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import 'setup_statistics_page_model.dart';
import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';
import '../../utils/functions.dart';
import '../../utils/value_tracker.dart';

class SetupStatisticPageBloc
    extends Bloc<SetupStatisticPageEvent, SetupStatisticPageState>
    with AdemActionHelper {
  SetupStatisticPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
    on<UpdateData>(_mapUpdateDataToState);
  }

  Adem get _adem => AppDelegate().adem;

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<SetupStatisticPageState> emit,
  ) async {
    emit(DataFetching());

    final manager = ParamFormatManager();

    try {
      final map = await fetchForParameters([..._params]);

      if (isCancelCommunication) throw CancelAdemCommunication();

      AppDelegate().cacheMeasure(
        _adem.measureCache.copyWith(
          isDotShowed: manager.autoDecode(Param.showDot, map),
        ),
      );

      final info = SetupStatisticsPageModel(
        buildValueTracker(manager.autoDecode(Param.uncPeakFlowRate, map)),
        combineDateTime(
          manager.autoDecode(Param.uncPeakFlowRateDate, map),
          manager.autoDecode(Param.uncPeakFlowRateTime, map),
        ),
        buildValueTracker(manager.autoDecode(Param.maxPress, map)),
        combineDateTime(
          manager.autoDecode(Param.maxPressDate, map),
          manager.autoDecode(Param.maxPressTime, map),
        ),
        buildValueTracker(manager.autoDecode(Param.minPress, map)),
        combineDateTime(
          manager.autoDecode(Param.minPressDate, map),
          manager.autoDecode(Param.minPressTime, map),
        ),
        buildValueTracker(manager.autoDecode(Param.maxTemp, map)),
        combineDateTime(
          manager.autoDecode(Param.maxTempDate, map),
          manager.autoDecode(Param.maxTempTime, map),
        ),
        buildValueTracker(manager.autoDecode(Param.minTemp, map)),
        combineDateTime(
          manager.autoDecode(Param.minTempDate, map),
          manager.autoDecode(Param.minTempTime, map),
        ),
        buildValueTracker(manager.autoDecode(Param.maxCaseTemp, map)),
        buildValueTracker(manager.autoDecode(Param.minCaseTemp, map)),
        buildValueTracker(DataParser.asInt(map[Param.provingVol])),
        buildValueTracker(manager.autoDecode(Param.backupIndexCounter, map)),
        buildValueTracker(_adem.measureCache.isDotShowed),
      );

      emit(DataReady(info));
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }

  Future<void> _mapUpdateDataToState(
    UpdateData event,
    Emitter<SetupStatisticPageState> emit,
  ) async {
    emit(DataUpdating());

    final user = AppDelegate().user;
    final info = event.info;

    try {
      if (user == null) throw NullSafety.user.exception;

      final tasks = {
        if (info.peakUncFlowRate?.isEdited ?? false)
          Param.uncPeakFlowRate: '00000000',
        if (info.isDotShowed?.isEdited ?? false)
          Param.showDot: info.isDotShowed!.value ? '00000001' : '00000000',
        if (info.maxGasPress?.isEdited ?? false) Param.maxPress: '00000000',
        if (info.minGasPress?.isEdited ?? false) Param.minPress: '00000000',
        if (info.maxGasTemp?.isEdited ?? false) Param.maxTemp: '00000000',
        if (info.minGasTemp?.isEdited ?? false) Param.minTemp: '00000000',
        if (info.maxCaseTemp?.isEdited ?? false) Param.maxCaseTemp: '00000000',
        if (info.minCaseTemp?.isEdited ?? false) Param.minCaseTemp: '00000000',
        if (info.provingVol?.isEdited ?? false) Param.provingVol: '00000000',
        if (info.backupIdxCtr?.isEdited ?? false)
          Param.backupIndexCounter: info.backupIdxCtr!.value.toAdemStringFmt(
            decimal: Param.backupIndexCounter.decimal(AppDelegate().adem),
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

abstract class SetupStatisticPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends SetupStatisticPageEvent {}

class UpdateData extends SetupStatisticPageEvent {
  final String accessCode;
  final SetupStatisticsPageModel info;

  UpdateData(this.accessCode, this.info);
}

// ---- State ----

abstract class SetupStatisticPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends SetupStatisticPageState {}

class DataFetching extends SetupStatisticPageState {}

class DataUpdating extends SetupStatisticPageState {}

class DataReady extends SetupStatisticPageState {
  final SetupStatisticsPageModel info;

  DataReady(this.info);
}

class DataUpdated extends SetupStatisticPageState {}

class FetchDataFailed extends SetupStatisticPageState {
  final Object error;

  FetchDataFailed(this.error);
}

class UpdateDataFailed extends SetupStatisticPageState {
  final Object error;

  UpdateDataFailed(this.error);
}

const _params = {
  Param.uncPeakFlowRate,
  Param.uncPeakFlowRateDate,
  Param.uncPeakFlowRateTime,
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
  Param.provingVol,
  Param.backupIndexCounter,
  Param.showDot,
};
