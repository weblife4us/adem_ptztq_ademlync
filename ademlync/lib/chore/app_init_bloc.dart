import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/app_delegate.dart';
import '../utils/enums.dart';
import '../utils/functions.dart';
import '../utils/preference_unit.dart';
import 'managers/cloud_file_manager.dart';

class AppInitBloc extends Bloc<AppInitEvent, AppInitState> {
  AppInitBloc() : super(Uninitialized()) {
    on<Init>(_mapInitToState);
  }

  Future<void> _mapInitToState(Init event, Emitter<AppInitState> emit) async {
    emit(Initializing());

    final app = AppDelegate();

    try {
      await Future.wait([
        // Init the preference unit
        PreferenceUtils.getInstance(),

        // Init the package info
        app.initPackageInfo(),
      ]);

      if (await app.isGrantedStorage) {
        await app.initLocalStorage();
        await CloudFileManager().syncUploadedFiles();
      }

      emit(Initialized());

      app.setMainTimer();

      switch (await determineLoginState()) {
        case LoginState.unauthenticated:
          emit(Unauthenticated(false));
          break;

        case LoginState.authenticated:
          emit(Authenticated());
          break;

        case LoginState.expired:
          await AppDelegate().removeUserCredential();
          CloudManager().logout();
          emit(Unauthenticated(true));
          break;
      }
    } catch (e) {
      emit(InitializeFailed(e));
    }
  }
}

// ---- Event ----

abstract class AppInitEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class Init extends AppInitEvent {}

// ---- State ----

abstract class AppInitState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class Uninitialized extends AppInitState {}

class Initializing extends AppInitState {}

class Initialized extends AppInitState {}

class Authenticated extends AppInitState {}

class Unauthenticated extends AppInitState {
  final bool isExpired;

  Unauthenticated(this.isExpired);
}

class InitializeFailed extends AppInitState {
  final Object error;

  InitializeFailed(this.error);
}
