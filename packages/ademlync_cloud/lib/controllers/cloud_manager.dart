import 'dart:convert';
import 'dart:io';

import 'package:ademlync_device/ademlync_device.dart';

import '../models/user.dart';
import '../models/user_created_status.dart';
import '../utils/api_helper.dart';
import '../utils/enums.dart';

part 'file_manager.dart';
part 'user_manager.dart';

class CloudManager {
  CloudManager._internal();
  static final _manager = CloudManager._internal();

  factory CloudManager() => _manager;

  final _userManager = UserManager();
  final _fileManager = FileManager();

  /// Gets the current authenticated user, if any.
  CredentialUser? get user => _userManager.user;

  Future<bool?> getMfaStatus(String email) => _userManager.getMfaStatus(email);

  Future<String?> enableMfa(String email) => _userManager.enableMfa(email);

  Future<void> verifyMfa(String email, String otp) =>
      _userManager.verifyMfa(email, otp);

  Future<void> mfaChallenge(String email, String otp, String session) =>
      _userManager.mfaChallenge(email, otp, session);

  Future<bool> discoverIdp(String email) => _userManager.discoverIdp(email);

  /// Logs in a user with the provided email and password.
  Future<String?> login(String email, String password) =>
      _userManager.login(email, password);

  /// Logs in a new user with the provided email, password, and new password.
  Future<void> loginAsNewUser(
    String email,
    String password,
    String newPassword,
  ) => _userManager.loginAsNewUser(email, password, newPassword);

  /// Logs in a limited user.
  Future<void> loginAsLimitedUser() => _userManager.loginAsLimiterUser();

  /// Logs out the current user.
  void logout() => _userManager.logout();

  /// Initiates a password reset request for the given email.
  Future<void> forgotPassword(String email) =>
      _userManager.forgotPassword(email);

  /// Resets the password for the given email using a verification code.
  Future<void> resetPassword(String email, String password, String code) =>
      _userManager.resetPassword(email, password, code);

  /// Fetches a list of users accessible to the current user.
  Future<List<User>> fetchUsers() => _userManager.fetchUsers(user!);

  /// Fetches a list of groups accessible to the current user.
  Future<List<Group>> fetchGroups() => _userManager.fetchGroups(user!);

  /// Creates a new user with the specified email and group.
  Future<void> createUser(String email, String group) =>
      _userManager.create(user!, email, group);

  /// Updates an existing user’s email and group.
  Future<void> updateUser(String email, String group) =>
      _userManager.update(user!, email, group);

  /// Deletes a user with the specified email.
  Future<void> deleteUser(String email) => _userManager.delete(user!, email);

  /// Fetches a list of files based on log type and serial number.
  Future<List<String>> fetchFiles(CloudFileType type, String sn) =>
      _fileManager.fetchFiles(user!, type, sn);

  /// Fetches a list of folders based on log type.
  Future<List<String>> fetchFolders(CloudFileType type) =>
      _fileManager.fetchFolders(user!, type);

  /// Requests an email with a download link for the specified file.
  Future<void> requestDownloadFileEmail(String filePath) =>
      _fileManager.requestDownloadFileEmail(user!, filePath);

  /// Requests an email with a download link for the multi-file.
  Future<void> requestDownloadMultiFileEmail(List<String> filePaths) =>
      _fileManager.requestDownloadMultiFileEmail(user!, filePaths);

  /// Uploads a file to the specified folder with given details and format.
  Future<void> uploadFile(
    String sn,
    String folderPath,
    String filePath,
    String filename,
    ExportFormat fmt,
  ) => _fileManager.uploadFile(user!, sn, folderPath, filePath, filename, fmt);

  /// Uploads a JSON file containing user data and returns the creation status.
  Future<UserCreatedStatus> uploadUsersJson(Map<String, dynamic> file) async =>
      await _fileManager.uploadUsersJson(user!, file);
}
