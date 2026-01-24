part of './cloud_manager.dart';

/// Handles user-related operations.
class UserManager {
  // Singleton
  UserManager._internal();
  static final _manager = UserManager._internal();

  factory UserManager() => _manager;

  CredentialUser? _user;

  CredentialUser? get user => _user;

  String? _pwd;

  void import(String json) {
    _user = CredentialUser.fromJson(jsonDecode(json));
  }

  String export() {
    try {
      return jsonEncode(_user!.toJson());
    } catch (e) {
      throw StateError('User is null');
    }
  }

  Future<bool?> getMfaStatus(String email) async {
    if (_pwd == null) return null;

    final response = await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.getMfaStatus,
        data: {'username': email, 'new_password': _pwd},
      ),
    );

    if (response case {'mfaEnabled': bool isEnabled}) {
      return isEnabled;
    }
    return null;
  }

  Future<String?> enableMfa(String email) async {
    if (_pwd == null) return null;

    final response = await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.enableMfa,
        data: {'username': email, 'new_password': _pwd},
      ),
    );

    if (response case {'setupKey': String setupKey}) {
      return setupKey;
    }
    return null;
  }

  Future<void> verifyMfa(String email, String totp) async {
    if (_pwd == null) return;

    await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.verifyMfa,
        data: {'username': email, 'new_password': _pwd, 'totpCode': totp},
      ),
    );
  }

  Future<void> mfaChallenge(String email, String totp, String session) async {
    final response = await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.mfaChallenge,
        data: {'username': email, 'challengeAnswer': totp, 'session': session},
      ),
    );

    final user = CredentialUser.fromJson(response);
    _user = user;
  }

  Future<bool> discoverIdp(String email) async {
    final response = await ApiHelper.post(
      ApiRequest(endpoint: ApiHelper.discoverIdp, data: {'username': email}),
    );

    if (response case {'hasIdp': bool hasIdp}) {
      return hasIdp;
    }
    return false;
  }

  /// Logs in with the [email] and [password].
  Future<String?> login(String email, String password) async {
    final response = await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.signIn,
        data: {'username': email, 'new_password': password},
      ),
    );

    if (response case {'session': String session}) {
      _pwd = password;
      return session;
    }

    final user = CredentialUser.fromJson(response);
    _user = user;
    _pwd = password;
    return null;
  }

  /// Logs in as a new `user` with the [email], [password], and [newPassword].
  Future<void> loginAsNewUser(
    String email,
    String password,
    String newPassword,
  ) async {
    final response = await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.signIn,
        data: {
          'username': email,
          'temp_password': password,
          'new_password': newPassword,
        },
      ),
    );
    final user = CredentialUser.fromJson(response);
    _user = user;
    _pwd = newPassword;
  }

  /// Logs in as a `limited user`.
  Future<void> loginAsLimiterUser() async {
    _user = CredentialUser.limited();
  }

  /// Logs out the `current user`.
  void logout() {
    _user = null;
  }

  /// Send `verification code` with the `email`.
  Future<void> forgotPassword(String email) async {
    await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.userForgotPassword,
        data: {'username': email},
      ),
    );
  }

  /// Reset `password` with the `verification code` and `new password`.
  Future<void> resetPassword(String email, String password, String code) async {
    await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.userConfirmForgotPassword,
        data: {
          'username': email,
          'new_password': password,
          'verification_code': code,
        },
      ),
    );
  }

  /// Fetches all `users`.
  Future<List<User>> fetchUsers(CredentialUser user) async {
    final response = await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.userList,
        data: {'cognito_group': user.cognitoGroup, 'username': user.email},
        accessToken: user.credential.accessToken,
      ),
    );
    return (response['users'] as List)
        .map((e) {
          try {
            return User.fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<User>()
        .toList();
  }

  /// Fetches all `groups`.
  Future<List<Group>> fetchGroups(CredentialUser user) async {
    final response = await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.userGroup,
        data: {'cognito_group': user.cognitoGroup, 'username': user.email},
        accessToken: user.credential.accessToken,
      ),
    );
    return (response['groups'] as List).map((e) => mapGroup(e)).toList();
  }

  /// Creates a new `user` with the [email] and [group].
  Future<void> create(CredentialUser user, String email, String group) async {
    await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.userCreate,
        data: {
          'cognito_group': user.cognitoGroup,
          'requesting_user': user.email,
          'email': email,
          'group': group,
        },
        accessToken: user.credential.accessToken,
      ),
    );
  }

  /// Updates the `user` with the [email] and [group].
  Future<void> update(CredentialUser user, String email, String group) async {
    await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.userModify,
        data: {
          'cognito_group': user.cognitoGroup,
          'username': user.email,
          'username_to_modify': email,
          'new_group': group,
        },
        accessToken: user.credential.accessToken,
      ),
    );
  }

  /// Deletes the `user` with the [email].
  Future<void> delete(CredentialUser user, String email) async {
    await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.userDelete,
        data: {
          'cognito_group': user.cognitoGroup,
          'username': user.email,
          'username_to_delete': email,
        },
        accessToken: user.credential.accessToken,
      ),
    );
  }
}
