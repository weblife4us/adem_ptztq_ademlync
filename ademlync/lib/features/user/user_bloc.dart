import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_delegate.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<UserIdpDiscovered>(_onUserIdpDiscovered);
    on<UserMfaChallenged>(_onUserMfaChallenged);
    on<UserLoggedIn>(_onUserLoggedIn);
    on<UserNewLoggedIn>(_onUserNewLoggedIn);
    on<UserLimitedLoggedIn>(_onUserLimitedLoggedIn);
    on<UserLoggedOut>(_onUserLoggedOut);
    on<UserFetched>(_onUserFetched);
    on<UserGrpFetched>(_onUserGrpFetched);
    on<UserCreated>(_onUserCreated);
    on<UserDeleted>(_onUserDeleted);
    on<UserUpdated>(_onUserUpdated);
    on<UserPwdForgot>(_onUserPwdForgot);
    on<UserPwdReset>(_onUserPwdReset);
  }

  Future<void> _onUserIdpDiscovered(
    UserIdpDiscovered event,
    Emitter<UserState> emit,
  ) async {
    emit(UserIdpDiscoverInProgressed());

    try {
      final hasIdp = await CloudManager().discoverIdp(event.email);

      emit(UserIdpDiscoverSuccess(hasIdp));
    } catch (e) {
      emit(UserIdpDiscoverFailure(e));
    }
  }

  Future<void> _onUserMfaChallenged(
    UserMfaChallenged event,
    Emitter<UserState> emit,
  ) async {
    emit(UserMfaChallengeInProgressed());

    try {
      await CloudManager().mfaChallenge(event.email, event.otp, event.session);

      final user = AppDelegate().user ?? (throw Exception('User is null'));
      if (!user.isLimitedUser) await AppDelegate().storeUserCredential();

      emit(UserMfaChallengeSuccess());
    } catch (e) {
      emit(UserMfaChallengeFailure(e));
    }
  }

  Future<void> _onUserLoggedIn(
    UserLoggedIn event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoginInProgressed());

    try {
      final session = await CloudManager().login(event.email, event.pwd);
      if (session != null) {
        emit(UserMfaRequired(session));
      } else {
        final user = AppDelegate().user ?? (throw Exception('User is null'));
        if (!user.isLimitedUser) await AppDelegate().storeUserCredential();
        emit(UserLoginSuccess());
      }
    } catch (e) {
      emit(UserLoginFailure(e));
    }
  }

  Future<void> _onUserNewLoggedIn(
    UserNewLoggedIn event,
    Emitter<UserState> emit,
  ) async {
    emit(UserNewLoginInProgressed());

    try {
      await CloudManager().loginAsNewUser(
        event.email,
        event.tempPwd,
        event.newPwd,
      );

      final user = AppDelegate().user ?? (throw Exception('User is null'));
      if (!user.isLimitedUser) await AppDelegate().storeUserCredential();

      emit(UserNewLoginSuccess());
    } catch (e) {
      emit(UserNewLoginFailure(e));
    }
  }

  Future<void> _onUserLimitedLoggedIn(
    UserLimitedLoggedIn event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLimitedLoginInProgressed());

    try {
      await CloudManager().loginAsLimitedUser();

      final user = AppDelegate().user ?? (throw Exception('User is null'));
      if (!user.isLimitedUser) await AppDelegate().storeUserCredential();

      emit(UserLimitedLoginSuccess());
    } catch (e) {
      emit(UserLimitedLoginFailure(e));
    }
  }

  Future<void> _onUserLoggedOut(
    UserLoggedOut event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLogoutInProgressed());

    try {
      CloudManager().logout();

      emit(UserLogoutSuccess());
    } catch (e) {
      emit(UserLogoutFailure(e));
    }
  }

  Future<void> _onUserFetched(
    UserFetched event,
    Emitter<UserState> emit,
  ) async {
    emit(UserFetchInProgress());

    try {
      final users = await CloudManager().fetchUsers();

      users
        ..removeWhere((e) => e.email == UserManager().user?.email)
        ..sort((a, b) => a.cognitoGroup.compareTo(b.cognitoGroup));

      emit(UserFetchSuccess(users));
    } catch (e) {
      emit(UserFetchFailure(e));
    }
  }

  Future<void> _onUserGrpFetched(
    UserGrpFetched event,
    Emitter<UserState> emit,
  ) async {
    emit(UserGrpFetchInProgress());

    try {
      final groups = await CloudManager().fetchGroups();

      emit(UserGrpFetchSuccess(groups));
    } catch (e) {
      emit(UserGrpFetchFailure(e));
    }
  }

  Future<void> _onUserCreated(
    UserCreated event,
    Emitter<UserState> emit,
  ) async {
    emit(UserCreateInProgress());

    try {
      await CloudManager().createUser(event.email, event.group);

      emit(UserCreateSuccess());
    } catch (e) {
      emit(UserCreateFailure(e));
    }
  }

  Future<void> _onUserDeleted(
    UserDeleted event,
    Emitter<UserState> emit,
  ) async {
    emit(UserDeleteInProgress());

    try {
      await CloudManager().deleteUser(event.email);

      emit(UserDeleteSuccess());
    } catch (e) {
      emit(UserDeleteFailure(e));
    }
  }

  Future<void> _onUserUpdated(
    UserUpdated event,
    Emitter<UserState> emit,
  ) async {
    emit(UserUpdateInProgress());

    try {
      await CloudManager().updateUser(event.email, event.group);

      emit(UserUpdateSuccess());
    } catch (e) {
      emit(UserUpdateFailure(e));
    }
  }

  Future<void> _onUserPwdForgot(
    UserPwdForgot event,
    Emitter<UserState> emit,
  ) async {
    emit(UserPwdForgetInProgress());

    try {
      await CloudManager().forgotPassword(event.email);

      emit(UserPwdForgetSuccess());
    } catch (e) {
      emit(UserPwdForgetFailure(e));
    }
  }

  Future<void> _onUserPwdReset(
    UserPwdReset event,
    Emitter<UserState> emit,
  ) async {
    emit(UserPwdResetInProgress());

    try {
      // Reset the password
      await CloudManager().resetPassword(event.email, event.newPwd, event.code);

      emit(UserPwdResetSuccess());
    } catch (e) {
      emit(UserPwdResetFailure(e));
    }
  }
}

sealed class UserEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class UserIdpDiscovered extends UserEvent {
  final String email;

  UserIdpDiscovered(this.email);
}

final class UserMfaChallenged extends UserEvent {
  final String email;
  final String otp;
  final String session;

  UserMfaChallenged(this.email, this.otp, this.session);
}

final class UserLoggedIn extends UserEvent {
  final String email;
  final String pwd;

  UserLoggedIn(this.email, this.pwd);
}

final class UserNewLoggedIn extends UserEvent {
  final String email;
  final String tempPwd;
  final String newPwd;

  UserNewLoggedIn(this.email, this.tempPwd, this.newPwd);
}

final class UserLimitedLoggedIn extends UserEvent {}

final class UserLoggedOut extends UserEvent {}

final class UserFetched extends UserEvent {}

final class UserGrpFetched extends UserEvent {}

final class UserCreated extends UserEvent {
  final String email;
  final String group;

  UserCreated(this.email, this.group);
}

final class UserDeleted extends UserEvent {
  final String email;

  UserDeleted(this.email);
}

final class UserUpdated extends UserEvent {
  final String email;
  final String group;

  UserUpdated(this.email, this.group);
}

final class UserPwdForgot extends UserEvent {
  final String email;

  UserPwdForgot(this.email);
}

final class UserPwdReset extends UserEvent {
  final String email;
  final String newPwd;
  final String code;

  UserPwdReset(this.email, this.newPwd, this.code);
}

sealed class UserState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class UserInitial extends UserState {}

final class UserIdpDiscoverInProgressed extends UserState {}

final class UserIdpDiscoverSuccess extends UserState {
  final bool hasIdp;

  UserIdpDiscoverSuccess(this.hasIdp);
}

final class UserIdpDiscoverFailure extends UserState {
  final Object error;

  UserIdpDiscoverFailure(this.error);
}

final class UserMfaChallengeInProgressed extends UserState {}

final class UserMfaChallengeSuccess extends UserState {}

final class UserMfaChallengeFailure extends UserState {
  final Object error;

  UserMfaChallengeFailure(this.error);
}

final class UserLoginInProgressed extends UserState {}

final class UserLoginSuccess extends UserState {}

final class UserLoginFailure extends UserState {
  final Object error;

  UserLoginFailure(this.error);
}

final class UserNewLoginInProgressed extends UserState {}

final class UserNewLoginSuccess extends UserState {}

final class UserNewLoginFailure extends UserState {
  final Object error;

  UserNewLoginFailure(this.error);
}

final class UserLimitedLoginInProgressed extends UserState {}

final class UserLimitedLoginSuccess extends UserState {}

final class UserLimitedLoginFailure extends UserState {
  final Object error;

  UserLimitedLoginFailure(this.error);
}

final class UserLogoutInProgressed extends UserState {}

final class UserLogoutSuccess extends UserState {}

final class UserLogoutFailure extends UserState {
  final Object error;

  UserLogoutFailure(this.error);
}

final class UserFetchInProgress extends UserState {}

final class UserFetchSuccess extends UserState {
  final List<User> users;

  UserFetchSuccess(this.users);
}

final class UserFetchFailure extends UserState {
  final Object error;

  UserFetchFailure(this.error);
}

final class UserGrpFetchInProgress extends UserState {}

final class UserGrpFetchSuccess extends UserState {
  final List<Group> groups;

  UserGrpFetchSuccess(this.groups);
}

final class UserGrpFetchFailure extends UserState {
  final Object error;

  UserGrpFetchFailure(this.error);
}

final class UserCreateInProgress extends UserState {}

final class UserCreateSuccess extends UserState {}

final class UserCreateFailure extends UserState {
  final Object error;

  UserCreateFailure(this.error);
}

final class UserDeleteInProgress extends UserState {}

final class UserDeleteSuccess extends UserState {}

final class UserDeleteFailure extends UserState {
  final Object error;

  UserDeleteFailure(this.error);
}

final class UserUpdateInProgress extends UserState {}

final class UserUpdateSuccess extends UserState {}

final class UserUpdateFailure extends UserState {
  final Object error;

  UserUpdateFailure(this.error);
}

final class UserPwdForgetInProgress extends UserState {}

final class UserPwdForgetSuccess extends UserState {}

final class UserPwdForgetFailure extends UserState {
  final Object error;

  UserPwdForgetFailure(this.error);
}

final class UserPwdResetInProgress extends UserState {}

final class UserPwdResetSuccess extends UserState {}

final class UserPwdResetFailure extends UserState {
  final Object error;

  UserPwdResetFailure(this.error);
}

final class UserMfaRequired extends UserState {
  final String session;

  UserMfaRequired(this.session);
}
