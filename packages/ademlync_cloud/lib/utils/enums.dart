import 'package:json_annotation/json_annotation.dart';

enum ApiContentType {
  json('application/json'),
  pdf('application/pdf'),
  xlsx('application/xlsx');

  final String key;

  const ApiContentType(this.key);
}

@JsonEnum(valueField: 'apiValue')
enum UserRole {
  superAdmin('superadmin'),
  admin('admin'),
  technician('technician'),
  limitedUser('');

  final String apiValue;

  const UserRole(this.apiValue);
}

enum UserAccess {
  readAdem,
  writeAdem,
  calibrateAdem,
  changeAdemAccessCode,
  changeAdemSuperAccessCode,
  crossCompanyManagement,
  pullLogFromCloud,
  pushLogToCloud,
  createUserInCloud,
  editUserInCloud,
  deleteUserFromCloud,
}

enum ExportFormat {
  excel,
  pdf,
  json;

  static ExportFormat? fromFilename(String filename) =>
      switch (filename.split('.').last) {
        'xlsx' => ExportFormat.excel,
        'pdf' => ExportFormat.pdf,
        'json' => ExportFormat.json,
        _ => null,
      };
}
