import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MfaBloc extends Bloc<MfaEvent, MfaStates> {
  MfaBloc() : super(MfaInitial()) {
    on<MfaEnabled>(_onMfaEnabled);
    on<MfaVerified>(_onMfaVerified);
  }

  Future<void> _onMfaEnabled(MfaEnabled event, Emitter<MfaStates> emit) async {
    emit(MfaEnableInProgress());

    try {
      final setupKey = await CloudManager().enableMfa(event.email);
      if (setupKey == null) throw Exception('Setup key Not found');

      emit(MfaEnableSuccess(setupKey));
    } catch (e) {
      emit(MfaEnableFailure(e));
    }
  }

  Future<void> _onMfaVerified(
    MfaVerified event,
    Emitter<MfaStates> emit,
  ) async {
    emit(MfaVerifyInProgress());

    try {
      await CloudManager().verifyMfa(event.email, event.otp);

      emit(MfaVerifySuccess());
    } catch (e) {
      emit(MfaVerifyFailure(e));
    }
  }
}

sealed class MfaEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class MfaEnabled extends MfaEvent {
  final String email;

  MfaEnabled(this.email);
}

final class MfaVerified extends MfaEvent {
  final String email;
  final String otp;

  MfaVerified(this.email, this.otp);
}

sealed class MfaStates extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class MfaInitial extends MfaStates {}

final class MfaEnableInProgress extends MfaStates {}

final class MfaEnableSuccess extends MfaStates {
  final String setupKey;

  MfaEnableSuccess(this.setupKey);
}

final class MfaEnableFailure extends MfaStates {
  final Object error;

  MfaEnableFailure(this.error);
}

final class MfaVerifyInProgress extends MfaStates {}

final class MfaVerifySuccess extends MfaStates {}

final class MfaVerifyFailure extends MfaStates {
  final Object error;

  MfaVerifyFailure(this.error);
}
