import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---- BLoC ----

class SLGDebugBloc extends Bloc<SLGDebugEvent, SLGDebugState>
    with AdemActionHelper {
  int _fetchCount = 0;

  SLGDebugBloc() : super(SLGDataNotReady()) {
    on<StartReading>(_mapStartReadingToState);
  }

  Future<void> _mapStartReadingToState(
    StartReading event,
    Emitter<SLGDebugState> emit,
  ) async {
    emit(SLGDataFetching());

    final manager = AdemManager();
    Timer? timer;
    bool isConnectedToAdem = false;

    _fetchCount = 0;

    try {
      await manager.wakeUp();
      await manager.connect();
      isConnectedToAdem = true;

      // Auto-disconnect timeout (5 minutes for debug session)
      final completer = Completer<void>();
      timer = Timer(const Duration(seconds: 300), () {
        if (!completer.isCompleted) {
          completer.completeError(
            const AdemCommError(AdemCommErrorType.communicationTimeout),
          );
        }
      });

      do {
        if (isCancelCommunication || completer.isCompleted) break;

        try {
          // Read 3 SLG47011 debug values (AudAddr 990, 991, 992)
          final r0 = await manager.read(990); // DataBuffer0 Result
          final r1 = await manager.read(991); // DataBuffer1 Result
          final r2 = await manager.read(992); // ADC raw

          final raw0 = DataParser.asInt(r0.body) ?? 0;
          final raw1 = DataParser.asInt(r1.body) ?? 0;
          final rawAdc = DataParser.asInt(r2.body) ?? 0;

          emit(SLGDataFetched(
            SLGData(raw0, raw1, rawAdc),
            ++_fetchCount,
          ));
        } catch (e) {
          if (e case AdemCommError(
            :final type,
          ) when type == AdemCommErrorType.receiveTimeout) {
            // Retry on timeout
            await Future.delayed(const Duration(milliseconds: 200));
            continue;
          } else {
            rethrow;
          }
        }

        await Future.delayed(const Duration(milliseconds: 1000));
      } while (!isCancelCommunication && !completer.isCompleted);

      if (!completer.isCompleted) completer.complete();
      await completer.future;
    } catch (e) {
      emit(SLGDataError(e));
    } finally {
      try {
        if (isConnectedToAdem) {
          await manager.disconnect(timeout: disconnectLogTimeoutInMs);
        }
      } catch (_) {}
      timer?.cancel();
    }
  }
}

// ---- Data Model ----

class SLGData {
  final int buffer0Raw; // DataBuffer0 Result word (16-bit MSB-aligned)
  final int buffer1Raw; // DataBuffer1 Result word (16-bit MSB-aligned)
  final int adcRaw;     // ADC direct value (16-bit)

  const SLGData(this.buffer0Raw, this.buffer1Raw, this.adcRaw);

  // 14-bit right-aligned value (0-16383)
  int get buffer0_14bit => buffer0Raw >> 2;
  int get buffer1_14bit => buffer1Raw >> 2;
  int get adc_14bit => adcRaw >> 2;

  // 12-bit compatible value (0-4095), same as calibration system uses
  int get buffer0_12bit => buffer0Raw >> 4;
  int get buffer1_12bit => buffer1Raw >> 4;
  int get adc_12bit => adcRaw >> 4;
}

// ---- Events ----

abstract class SLGDebugEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class StartReading extends SLGDebugEvent {}

// ---- States ----

abstract class SLGDebugState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class SLGDataNotReady extends SLGDebugState {}

class SLGDataFetching extends SLGDebugState {}

class SLGDataFetched extends SLGDebugState {
  final SLGData data;
  final int fetchCount;

  SLGDataFetched(this.data, this.fetchCount);
}

class SLGDataError extends SLGDebugState {
  final Object error;

  SLGDataError(this.error);
}
