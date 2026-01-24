import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogFlowDpPageBloc extends Bloc<LogFlowDpPageEvent, LogFlowDpPageState>
    with AdemActionHelper {
  LogFlowDpPageBloc() : super(DataNotReady()) {
    on<FetchData>(_mapFetchDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchData event,
    Emitter<LogFlowDpPageState> emit,
  ) async {
    emit(DataFetching());

    int logNumber = 0;

    try {
      // Stream logs
      await for (var e in streamLogs(LogType.flowDp)) {
        // Map the log
        final log = LogParser.flowDp(e.body, ++logNumber);

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

abstract class LogFlowDpPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends LogFlowDpPageEvent {}

// ---- State ----

abstract class LogFlowDpPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends LogFlowDpPageState {}

class DataFetching extends LogFlowDpPageState {}

class LogFetched extends LogFlowDpPageState {
  final FlowDpLog log;

  LogFetched(this.log);
}

class DataReady extends LogFlowDpPageState {}

class FetchDataFailed extends LogFlowDpPageState {
  final Object error;

  FetchDataFailed(this.error);
}
