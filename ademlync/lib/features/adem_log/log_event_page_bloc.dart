import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_delegate.dart';
import '../../utils/enums.dart';

class LogEventPageBloc extends Bloc<LogEventPageEvent, LogEventPageState>
    with AdemActionHelper {
  LogEventPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<LogEventPageState> emit,
  ) async {
    emit(DataFetching());

    final app = AppDelegate();
    final user = app.user;

    try {
      if (user == null) throw NullSafety.user.exception;

      // Stream logs
      await for (var e in streamLogs(
        LogType.event,
        accessCode: event.accessCode,
        userId: user.id,
        from: event.dateTimeRange?.from,
        to: event.dateTimeRange?.to,
        isAdem25: app.adem.isAdem25,
      )) {
        // Map the log
        final logs = LogParser.event(e.body, app.adem, app.is24HTimeFmt);

        emit(LogFetched(logs));
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

abstract class LogEventPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends LogEventPageEvent {
  final String? accessCode;
  final LogTimeRange? dateTimeRange;

  FetchData(this.accessCode, this.dateTimeRange);
}

// ---- State ----

abstract class LogEventPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends LogEventPageState {}

class DataFetching extends LogEventPageState {}

class LogFetched extends LogEventPageState {
  final List<EventLog> logs;

  LogFetched(this.logs);
}

class DataReady extends LogEventPageState {}

class FetchDataFailed extends LogEventPageState {
  final Object error;

  FetchDataFailed(this.error);
}
