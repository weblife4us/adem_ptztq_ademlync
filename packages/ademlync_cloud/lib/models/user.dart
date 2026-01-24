import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/enums.dart';
import '../utils/functions.dart';

part './credential.dart';
part './group.dart';
part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  @JsonKey(readValue: emailReadValue)
  final String email;
  @JsonKey(readValue: groupReadValue, fromJson: mapGroup, toJson: _groupToJson)
  final Group group;

  /// Get the Cognito group
  String get cognitoGroup => group.rawData;

  /// Get the company
  String get company => group.company;

  /// Get the user role
  UserRole get role => group.role;

  /// Get the user permission
  Set<UserAccess> get permission => group.permission;

  /// Get the user id
  String get id => role.id;

  /// Determine if this is a super admin
  bool get isSuperAdmin => role == UserRole.superAdmin;

  /// Determine if this is a admin
  bool get isAdmin => role == UserRole.admin;

  /// Determine if this is a technician
  bool get isTechnician => role == UserRole.technician;

  /// Determine if this is a limited user
  bool get isLimitedUser => role == UserRole.limitedUser;

  /// Determine if user can read data from AdEM
  bool get canReadAdem => permission.contains(UserAccess.readAdem);

  /// Determine if user can write data to AdEM
  bool get canWriteAdem => permission.contains(UserAccess.writeAdem);

  /// Determine if user can calibration data to AdEM
  bool get canCalibrateAdem => permission.contains(UserAccess.calibrateAdem);

  /// Determine if user can change the access code to AdEM
  bool get canChangeAdemAccessCode =>
      permission.contains(UserAccess.changeAdemAccessCode);

  /// Determine if user can change the super access code to AdEM
  bool get canChangeAdemSuperAccessCode =>
      permission.contains(UserAccess.changeAdemSuperAccessCode);

  /// Determine if user can pull log from cloud
  bool get canPullLogFromCloud =>
      permission.contains(UserAccess.pullLogFromCloud);

  /// Determine if user can push log to cloud
  bool get canPushLogToCloud => permission.contains(UserAccess.pushLogToCloud);

  /// Determine if user can create user in cloud
  bool get canCreateUserInCloud =>
      permission.contains(UserAccess.createUserInCloud);

  /// Determine if user can edit user in cloud
  bool get canEditUserInCloud =>
      permission.contains(UserAccess.editUserInCloud);

  /// Determine if user can delete user in cloud
  bool get canDeleteUserFromCloud =>
      permission.contains(UserAccess.deleteUserFromCloud);

  const User(this.email, this.group);

  /// Create a limited user profile
  factory User.limitedAccess() => User('NA', Group.limited());

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  static Object? emailReadValue(Map<dynamic, dynamic> json, String string) =>
      json['username'] ?? json['email'];

  static Object? groupReadValue(Map<dynamic, dynamic> json, String string) =>
      json['cognito_group'] ?? json['group'];

  static String _groupToJson(Group value) => value.rawData;

  @override
  List<Object?> get props => [email, group];
}

Group mapGroup(String value) {
  final list = value.split('/');
  return Group.fromJson({
    'rawData': value,
    'company': list.first,
    'role': list.last,
  });
}

@JsonSerializable()
class CredentialUser extends User {
  @JsonKey(readValue: _credentialReadValue)
  final Credential credential;

  bool get isExpired => credential.tokenExpireTime.isBefore(DateTime.now());

  const CredentialUser(super.email, super.group, this.credential);

  /// Create a limited credential user profile
  factory CredentialUser.limited() =>
      CredentialUser('', Group.limited(), Credential.limited());

  factory CredentialUser.fromJson(Map<String, dynamic> json) =>
      _$CredentialUserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CredentialUserToJson(this);

  @override
  List<Object?> get props => [email, group, credential];
}

Object? _credentialReadValue(Map<dynamic, dynamic> json, String string) =>
    json['credential'] ?? json;
