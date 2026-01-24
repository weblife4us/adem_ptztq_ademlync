import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogQPageBloc extends Bloc<LogQPageEvent, LogQPageState>
    with AdemActionHelper {
  LogQPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<LogQPageState> emit,
  ) async {
    emit(DataFetching());

    int logNumber = 0;
    // Object? error;

    try {
      // Stream logs
      await for (var e in streamLogs(LogType.q)) {
        // Map the log
        final log = LogParser.q(e.body, ++logNumber);

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

abstract class LogQPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends LogQPageEvent {}

// ---- State ----

abstract class LogQPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends LogQPageState {}

class DataFetching extends LogQPageState {}

class LogFetched extends LogQPageState {
  final QLog log;

  LogFetched(this.log);
}

class DataReady extends LogQPageState {}

class FetchDataFailed extends LogQPageState {
  final Object error;

  FetchDataFailed(this.error);
}
