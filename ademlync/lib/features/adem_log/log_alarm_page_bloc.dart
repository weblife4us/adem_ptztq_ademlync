import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';

class LogAlarmPageBloc extends Bloc<LogAlarmPageEvent, LogAlarmPageState>
    with AdemActionHelper {
  LogAlarmPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<LogAlarmPageState> emit,
  ) async {
    emit(DataFetching());

    int logNumber = 0;

    // Determine the date time range filter
    final dateTimeRange = event.dateTimeRange ?? defaultLogRange;

    try {
      // Stream logs
      await for (var e in streamLogs(
        LogType.alarm,
        from: dateTimeRange.from,
        to: dateTimeRange.to,
        isAdem25: AppDelegate().adem.isAdem25,
      )) {
        // Map the log
        final log = LogParser.alarm(e.body, ++logNumber);

        if (log != null) emit(LogFetched(log));
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

abstract class LogAlarmPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends LogAlarmPageEvent {
  final LogTimeRange? dateTimeRange;

  FetchData(this.dateTimeRange);
}

// ---- State ----

abstract class LogAlarmPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends LogAlarmPageState {}

class DataFetching extends LogAlarmPageState {}

class LogFetched extends LogAlarmPageState {
  final AlarmLog log;

  LogFetched(this.log);
}

class DataReady extends LogAlarmPageState {}

class FetchDataFailed extends LogAlarmPageState {
  final Object error;

  FetchDataFailed(this.error);
}
