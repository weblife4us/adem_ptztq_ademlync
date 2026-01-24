import 'dart:convert';
import 'dart:io';

import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_cloud/models/user_created_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_delegate.dart';

class UserPageBloc extends Bloc<UserPageEvent, UserPageState> {
  UserPageBloc() : super(UserPageInitial()) {
    on<UserPageJsonUploaded>(_onUserPageJsonUploaded);
  }

  Future<void> _onUserPageJsonUploaded(
    UserPageJsonUploaded event,
    Emitter<UserPageState> emit,
  ) async {
    emit(UserPageJsonUploadInProgress());

    try {
      final user = AppDelegate().user ?? (throw Exception('User is null.'));
      final jsonString = await File(event.path).readAsString();

      final jsonData = jsonDecode(jsonString);
      if (jsonData is! Map<String, dynamic>) throw const FormatException();

      final updatedData = jsonData
        ..putIfAbsent('cognito_group', () => user.cognitoGroup)
        ..putIfAbsent('requesting_user', () => user.email);

      final status = await CloudManager().uploadUsersJson(updatedData);

      emit(UserPageJsonUploadSuccess(status));
    } on FormatException catch (_) {
      emit(UserPageJsonUploadFailure('Invalid JSON'));
    } catch (e) {
      emit(UserPageJsonUploadFailure(e));
    }
  }
}

// MARK: - Event
sealed class UserPageEvent extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class UserPageJsonUploaded extends UserPageEvent {
  final String path;

  UserPageJsonUploaded(this.path);
}

// MARK: - State
sealed class UserPageState extends Equatable {
  final date = DateTime.now();

  @override
  List<Object> get props => [date];
}

final class UserPageInitial extends UserPageState {}

final class UserPageJsonUploadInProgress extends UserPageState {}

final class UserPageJsonUploadSuccess extends UserPageState {
  final UserCreatedStatus status;

  UserPageJsonUploadSuccess(this.status);
}

final class UserPageJsonUploadFailure extends UserPageState {
  final Object error;

  UserPageJsonUploadFailure(this.error);
}
