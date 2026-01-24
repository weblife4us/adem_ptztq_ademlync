import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

const _email = 'andrewchan.romet@gmail.com';
const _password = 'Drewdrewx3x!';
const _newEmail = 'andrewchan.romet+test001@gmail.com';
const _newPassword = 'Drewdrewx3x!';

void main() {
  final manager = CloudManager();

  group('User Test 1 - ', () {
    test('Login (SuperAdmin)', () async {
      try {
        await manager.login(_email, _password);
      } catch (e) {
        if (kDebugMode) print(e);
        rethrow;
      }
    });

    test('Create user (technician)', () async {
      try {
        await manager.createUser(_newEmail, 'consumers/technician');
      } catch (e) {
        if (kDebugMode) print(e);
        rethrow;
      }
    });

    test('All users', () async {
      try {
        await manager.fetchUsers();
      } catch (e) {
        if (kDebugMode) print(e);
        rethrow;
      }
    });

    test('Modify user (technician -> admin)', () async {
      try {
        await manager.updateUser(_newEmail, 'consumers/admin');
      } catch (e) {
        if (kDebugMode) print(e);
        rethrow;
      }
    });
  });

  group('User Test 2 - ', () {
    test('Login as new user', () async {
      try {
        await manager.loginAsNewUser(_newEmail, 'zxBrO8O@', _newPassword);
      } catch (e) {
        if (kDebugMode) print(e);
        rethrow;
      }
    });

    test('Forgot password', () async {
      try {
        await manager.forgotPassword(_newEmail);
      } catch (e) {
        if (kDebugMode) print(e);
        rethrow;
      }
    });
  });

  group('User Test 3 - ', () {
    test('Reset password', () async {
      try {
        await manager.resetPassword(_newEmail, _newPassword, '161062');
      } catch (e) {
        if (kDebugMode) print(e);
        rethrow;
      }
    });

    test('Login (SuperAdmin)', () async {
      try {
        await manager.login(_email, _password);
      } catch (e) {
        if (kDebugMode) print(e);
        rethrow;
      }
    });

    test('Delete user', () async {
      try {
        await manager.deleteUser(_newEmail);
      } catch (e) {
        if (kDebugMode) print(e);
        rethrow;
      }
    });
  });
}
