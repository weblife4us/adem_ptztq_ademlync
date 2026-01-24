import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_delegate.dart';

class MenuBloc extends Bloc<MenuEvent, MenuStates> {
  CredentialUser? user;

  MenuBloc(super.state, this.user) {
    on<FetchData>(_onFetchData);
  }

  factory MenuBloc.init() {
    MenuStates? state;
    final user = AppDelegate().user;
    if (user != null) {
      state = DataReady();
    }
    return MenuBloc(state ?? DataNotReady(), user);
  }

  Future<void> _onFetchData(FetchData event, Emitter<MenuStates> emit) async {
    emit(DataFetching());
    try {
      user = AppDelegate().user!;
      emit(DataReady());
    } catch (e) {
      emit(FetchDataFailed(e));
    }
  }
}

// ---- Event ----

abstract class MenuEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchData extends MenuEvent {}

// ---- State ----

abstract class MenuStates extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class DataNotReady extends MenuStates {}

class DataFetching extends MenuStates {}

class DataReady extends MenuStates {}

class FetchDataFailed extends MenuStates {
  final Object error;

  FetchDataFailed(this.error);
}
