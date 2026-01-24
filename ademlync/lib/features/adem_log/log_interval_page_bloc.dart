import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'interval_log_fields_model.dart';
import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';

class LogIntervalPageBloc
    extends Bloc<LogIntervalPageEvent, LogIntervalPageState>
    with AdemActionHelper {
  IntervalLogFields? fields;
  List<IntervalLog>? logs;

  LogIntervalPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<LogIntervalPageState> emit,
  ) async {
    emit(DataFetching());

    logs = [];
    final adem = AppDelegate().adem;
    List<IntervalLogField>? intervalFields;
    int logNumber = 0;

    // Determine the interval type
    final intervalType = adem.measureCache.intervalType;

    // Determine the date time range filter
    final dateTimeRange = event.dateTimeRange ?? defaultLogRange;

    // Determine if the type is selectable
    if (intervalType == IntervalLogType.selectableFields) {
      // Determine interval fields
      intervalFields = adem.measureCache.intervalFields
          ?.where((e) => e != IntervalLogField.notSet)
          .whereType<IntervalLogField>()
          .toList();
      fields = IntervalLogFields(
        intervalFields?.toSet() ?? <IntervalLogField>{},
      );
    }

    try {
      // Stream logs
      await for (var e in streamLogs(
        LogType.interval,
        from: dateTimeRange.from,
        to: dateTimeRange.to,
        intervalType: intervalType,
      )) {
        // Map the log
        final log = LogParser.interval(
          e.body,
          ++logNumber,
          intervalType,
          adem.type,
          intervalFields,
          adem.volumeType,
        );

        if (log != null) logs!.add(log);

        emit(LogFetched());
      }

      emit(DataReady());
    } catch (e) {
      if (e is AdemCommError && e.type == AdemCommErrorType.receiveTimeout) {
        emit(DataReady());
      } else {
        emit(FetchDataFailed(e));
      }
    }
  }
}

// ---- Event ----

abstract class LogIntervalPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends LogIntervalPageEvent {
  final LogTimeRange? dateTimeRange;

  FetchData(this.dateTimeRange);
}

// ---- State ----

abstract class LogIntervalPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends LogIntervalPageState {}

class DataFetching extends LogIntervalPageState {}

class LogFetched extends LogIntervalPageState {}

class DataReady extends LogIntervalPageState {}

class FetchDataFailed extends LogIntervalPageState {
  final Object error;

  FetchDataFailed(this.error);
}
