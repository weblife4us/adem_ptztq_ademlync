import 'package:ademlync_device/utils/adem_param.dart';

import '../../utils/constants.dart';
import '../../utils/controllers/storage_manager.dart';
import '../../utils/functions.dart';
import '../../utils/preference_unit.dart';

const _key = uploadedFileKey;

class CloudFileManager {
  /// List of uploaded file paths.
  List<String> get uploadedFiles => _uploadedFiles;

  /// Gets non-uploaded log files by excluding uploaded ones.
  Future<List<String>> get nonUploadedLogs async {
    final uploadedFiles = _uploadedFiles;
    final folders = LogType.values.map((o) => o.folderName).toSet();
    final files = await _getAllFiles(folders);
    return files.where((o) => !uploadedFiles.contains(o)).toList();
  }

  /// Checks if there are any non-uploaded logs.
  Future<bool> get anyNonUploadedLogs async =>
      (await nonUploadedLogs).isNotEmpty;

  /// Syncs uploaded files by removing deleted ones.
  Future<void> syncUploadedFiles() async {
    final uploadedFiles = _uploadedFiles;
    final folders = LogType.values.map((o) => o.folderName).toSet();
    final files = await _getAllFiles(folders);
    final removedFiles = uploadedFiles.where((o) => !files.contains(o)).toSet();
    if (removedFiles.isNotEmpty) _dropUploadedFiles(removedFiles);
  }

  /// Saves new uploaded file paths.
  void saveUploadedFiles(Set<String> paths) =>
      _saveUploadedFiles(Set.of(_uploadedFiles)..addAll(paths));

  /// Drops specified uploaded file paths.
  void _dropUploadedFiles(Set<String> paths) =>
      _saveUploadedFiles(Set.of(_uploadedFiles)..removeAll(paths));

  /// Persists uploaded file paths to preferences.
  void _saveUploadedFiles(Set<String> paths) =>
      PreferenceUtils.setStringList(_key, paths.toList());

  /// Retrieves stored uploaded file paths.
  List<String> get _uploadedFiles => PreferenceUtils.getStringList(_key) ?? [];

  /// Gets all files from specified folders concurrently.
  Future<List<String>> _getAllFiles(Set<String> folderNames) async {
    final manager = StorageManager();
    final futures = folderNames.map((o) => manager.readFolder(o));
    final results = await Future.wait(futures);
    return results.expand((o) => o).toList();
  }
}
