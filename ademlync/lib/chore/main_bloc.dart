import 'dart:async';

import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/app_delegate.dart';

class MainBloc extends Bloc<MainEvent, MainState> with AdemActionHelper {
  final Set<MainEvent> pending = {};

  MainBloc() : super(MBBtDisconnectedState(false)) {
    on<MBBtConnEvent>(_mapMBBtConnEventToState);
    on<MBBtDiscEvent>(_mapMBBtDiscEventToState);
    on<MBAdemCacheEvent>(_mapMBAdemCacheEventToState);
    on<MBAdemCleanEvent>(_mapMBAdemCleanEventToState);
  }

  Future<void> _mapMBBtConnEventToState(
    MBBtConnEvent event,
    Emitter<MainState> emit,
  ) async {
    if (pending.every((e) => e is! MBBtConnEvent)) {
      pending.add(event);

      emit(MBBtConnectingState());

      final manager = BluetoothConnectionManager();
      int? battery;
      Object? error;

      try {
        await manager.connect(event.device);

        AppDelegate().bleConnStream = event.device.connectionState.listen((
          status,
        ) async {
          if (status == BluetoothConnectionState.disconnected) {
            add(MBBtDiscEvent(isAutoDisconnected: true));
          }
        });
      } catch (e) {
        error = e;
      }

      if (error == null) {
        try {
          battery = await manager.fetchBattery();
        } catch (e) {
          // Any error handle here?
        }
      }

      emit(
        error == null
            ? MBBtConnectedState(battery)
            : MBFailedState(event, error),
      );

      pending.remove(event);
    }
  }

  Future<void> _mapMBBtDiscEventToState(
    MBBtDiscEvent event,
    Emitter<MainState> emit,
  ) async {
    if (pending.every((e) => e is! MBBtDiscEvent)) {
      pending.add(event);

      emit(MBBtDisconnectingState());

      try {
        // Terminate device connection
        await BluetoothConnectionManager().disconnect();

        // Clean the adem cache
        AppDelegate().clearAdem();

        AppDelegate().bleConnStream?.cancel();
        AppDelegate().bleConnStream = null;

        emit(MBBtDisconnectedState(event.isAutoDisconnected));
      } catch (e) {
        emit(MBFailedState(event, e));
      }

      pending.remove(event);
    }
  }

  Future<void> _mapMBAdemCacheEventToState(
    MBAdemCacheEvent event,
    Emitter<MainState> emit,
  ) async {
    if (pending.every((e) => e is! MBAdemCacheEvent)) {
      pending.add(event);

      emit(MBAdemCachingState());

      try {
        // Fetch cache values
        await AppDelegate().fetchAdem();

        emit(MBAdemCachedState());
      } catch (e) {
        emit(MBFailedState(event, e));
      }

      pending.remove(event);
    }
  }

  Future<void> _mapMBAdemCleanEventToState(
    MBAdemCleanEvent event,
    Emitter<MainState> emit,
  ) async {
    if (pending.every((e) => e is! MBAdemCleanEvent)) {
      pending.add(event);

      emit(MBAdemCleaningState());

      try {
        // Clean adem cache
        AppDelegate().clearAdem();

        emit(MBAdemCleanedState());
      } catch (e) {
        emit(MBFailedState(event, e));
      }

      pending.remove(event);
    }
  }
}

// ---- Event ----

abstract class MainEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class MBBtConnEvent extends MainEvent {
  final BluetoothDevice device;

  MBBtConnEvent(this.device);
}

class MBBtDiscEvent extends MainEvent {
  final bool isSignOut;
  final bool isAutoDisconnected;

  MBBtDiscEvent({this.isSignOut = false, this.isAutoDisconnected = false});
}

class MBAdemCacheEvent extends MainEvent {}

class MBAdemCleanEvent extends MainEvent {}

// ---- State ----

abstract class MainState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class MBBtConnectingState extends MainState {}

class MBBtDisconnectingState extends MainState {}

class MBAdemCachingState extends MainState {}

class MBAdemCleaningState extends MainState {}

class MBBtConnectedState extends MainState {
  final int? battery;

  MBBtConnectedState(this.battery);
}

class MBBtDisconnectedState extends MainState {
  final bool isAutoDisconnected;

  MBBtDisconnectedState(this.isAutoDisconnected);
}

class MBAdemCachedState extends MainState {}

class MBAdemCleanedState extends MainState {}

class MBFailedState extends MainState {
  final MainEvent event;
  final Object error;

  MBFailedState(this.event, this.error);
}
