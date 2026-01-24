import 'dart:io';
import 'dart:typed_data';

import 'package:open_file_plus/open_file_plus.dart';

import '../app_delegate.dart';

class StorageManager {
  /// Saves a file with the given [filename] and [folderName] containing the provided [bytes].
  /// Returns the path of the saved file.
  Future<String> saveFile(
    String filename,
    String folderName,
    Uint8List bytes,
  ) async {
    final app = AppDelegate();

    // Check if storage permission is granted
    if (await app.isGrantedStorage) {
      final dirPath = app.localDirectoryPath;

      if (dirPath.isNotEmpty) {
        // Create the file and write the bytes to it
        final file = File('$dirPath/$folderName/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);

        return file.path;
      } else {
        throw StateError('Directory not found.');
      }
    } else {
      throw StateError('Storage permission denied.');
    }
  }

  /// Reads all files from the specified [folder] and returns their paths.
  /// If no folder is specified, returns an empty list.
  Future<List<String>> readFolder([String? folder]) async {
    final app = AppDelegate();

    // Check if storage permission is granted
    if (await app.isGrantedStorage) {
      final dirPath = app.localDirectoryPath;

      if (dirPath.isNotEmpty && folder != null) {
        final dir = Directory('$dirPath/$folder');

        // Ensure the directory exists, create it if it doesn't
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }

        // Return the list of file paths in the folder
        return dir.listSync().map((e) => e.path).toList();
      } else {
        throw StateError('Directory not found.');
      }
    } else {
      throw StateError('Storage permission denied.');
    }
  }

  /// Reads the content of a file at the given [path] as a string.
  Future<String> getFile(String path) async {
    return File(path).readAsString();
  }

  /// Opens a file located at the given [path] using the appropriate application.
  Future<OpenResult> openFile(String path) async {
    return await OpenFile.open(path);
  }
}
