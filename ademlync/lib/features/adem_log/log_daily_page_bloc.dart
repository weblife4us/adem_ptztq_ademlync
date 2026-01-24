import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';

class LogDailyPageBloc extends Bloc<LogDailyPageEvent, LogDailyPageState>
    with AdemActionHelper {
  LogDailyPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<LogDailyPageState> emit,
  ) async {
    emit(DataFetching());

    int logNumber = 0;

    // Determine the date time range filter
    final dateTimeRange = event.dateTimeRange ?? defaultLogRange;

    final adem = AppDelegate().adem;
    try {
      // Stream logs
      await for (var e in streamLogs(
        LogType.daily,
        from: dateTimeRange.from,
        to: dateTimeRange.to,
      )) {
        // Map the log
        final log = LogParser.daily(e.body, ++logNumber, adem.type);

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

abstract class LogDailyPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends LogDailyPageEvent {
  final LogTimeRange? dateTimeRange;

  FetchData(this.dateTimeRange);
}

// ---- State ----

abstract class LogDailyPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends LogDailyPageState {}

class DataFetching extends LogDailyPageState {}

class LogFetched extends LogDailyPageState {
  final DailyLog log;

  LogFetched(this.log);
}

class DataReady extends LogDailyPageState {}

class FetchDataFailed extends LogDailyPageState {
  final Object error;

  FetchDataFailed(this.error);
}
