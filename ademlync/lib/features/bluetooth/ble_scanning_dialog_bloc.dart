import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BleScanningDialogBloc
    extends Bloc<BleScanningDialogEvent, BleScanningDialogState>
    with AdemActionHelper {
  final Set<BleScanningDialogEvent> pendingEvents = {};

  BleScanningDialogBloc() : super(NotReadyState()) {
    on<BatteryFetchEvent>(_handleBatteryFetch);
  }

  Future<void> _handleBatteryFetch(
    BatteryFetchEvent event,
    Emitter<BleScanningDialogState> emit,
  ) async {
    emit(BatteryFetchingState());

    try {
      final battery = await BluetoothConnectionManager().fetchBattery();

      emit(BatteryFetchedState(battery));
    } catch (e) {
      emit(FailureState(e));
    }
  }
}

// ---- Event ----

abstract class BleScanningDialogEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class BatteryFetchEvent extends BleScanningDialogEvent {}

// ---- State ----

abstract class BleScanningDialogState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class NotReadyState extends BleScanningDialogState {}

class BatteryFetchingState extends BleScanningDialogState {}

class BatteryFetchedState extends BleScanningDialogState {
  final int? battery;

  BatteryFetchedState(this.battery);
}

class FailureState extends BleScanningDialogState {
  final Object error;

  FailureState(this.error);
}
