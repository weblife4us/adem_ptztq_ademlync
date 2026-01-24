import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/controllers/param_format_manager.dart';
import '../../utils/functions.dart';

class CheckAga8PageBloc extends Bloc<CheckAga8PageEvent, CheckAga8PageState>
    with AdemActionHelper {
  CheckAga8PageBloc() : super(NotReadyState()) {
    on<FetchEvent>(_mapFetchDataToState);
  }

  Future<void> _mapFetchDataToState(
    FetchEvent event,
    Emitter<CheckAga8PageState> emit,
  ) async {
    emit(FetchingState());

    final manager = ParamFormatManager();

    try {
      final map = await fetchForParameters([Param.aga8GasComponentMolar]);

      if (isCancelCommunication) throw CancelAdemCommunication();

      final aga8 = manager.autoDecode(Param.aga8GasComponentMolar, map);

      if (aga8 == null) throw Exception('Aga8 is null.');

      emit(FetchedState(aga8));
    } catch (e) {
      emit(FailureState(e));
    }
  }
}

// ---- Event ----

abstract class CheckAga8PageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class FetchEvent extends CheckAga8PageEvent {}

// ---- State ----

abstract class CheckAga8PageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

class NotReadyState extends CheckAga8PageState {}

class FetchingState extends CheckAga8PageState {}

class FetchedState extends CheckAga8PageState {
  final Aga8Config aga8;

  FetchedState(this.aga8);
}

class FailureState extends CheckAga8PageState {
  final Object error;

  FailureState(this.error);
}
