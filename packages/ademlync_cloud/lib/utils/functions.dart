import 'enums.dart';

extension UserRoleExt on UserRole {
  /// Identifies user in Event log.
  String get id => switch (this) {
    UserRole.superAdmin => '301',
    UserRole.admin => '302',
    UserRole.technician => '303',
    UserRole.limitedUser => '304',
  };

  /// Identifies user permission.
  Set<UserAccess> get permission => switch (this) {
    UserRole.superAdmin => {
      UserAccess.readAdem,
      UserAccess.writeAdem,
      UserAccess.calibrateAdem,
      UserAccess.changeAdemAccessCode,
      UserAccess.changeAdemSuperAccessCode,
      UserAccess.crossCompanyManagement,
      UserAccess.pullLogFromCloud,
      UserAccess.pushLogToCloud,
      UserAccess.createUserInCloud,
      UserAccess.editUserInCloud,
      UserAccess.deleteUserFromCloud,
    },
    UserRole.admin => {
      UserAccess.readAdem,
      UserAccess.writeAdem,
      UserAccess.calibrateAdem,
      UserAccess.changeAdemAccessCode,
      UserAccess.changeAdemSuperAccessCode,
      UserAccess.pullLogFromCloud,
      UserAccess.pushLogToCloud,
      UserAccess.createUserInCloud,
      UserAccess.editUserInCloud,
      UserAccess.deleteUserFromCloud,
    },
    UserRole.technician => {
      UserAccess.readAdem,
      UserAccess.writeAdem,
      UserAccess.pullLogFromCloud,
      UserAccess.pushLogToCloud,
    },
    UserRole.limitedUser => {UserAccess.readAdem},
  };
}
