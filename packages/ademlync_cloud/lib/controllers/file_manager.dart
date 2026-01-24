part of './cloud_manager.dart';

/// Handles log-related operations.
class FileManager {
  // Singleton
  FileManager._internal();
  static final _manager = FileManager._internal();

  factory FileManager() => _manager;

  /// Fetches all `files` with the [type] and [sn] (optional).
  Future<List<String>> fetchFiles(
    CredentialUser user,
    CloudFileType type,
    String sn,
  ) async {
    final response = await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.dataListFiles,
        data: {
          'cognito_group': user.cognitoGroup,
          'username': user.email,
          'log_type': type.apiValue,
          if (sn.isNotEmpty) 'AdEM_SN': sn,
        },
        accessToken: user.credential.accessToken,
      ),
    );
    return response['files'].cast<String>();
  }

  /// Fetches all `folders` with the [type].
  Future<List<String>> fetchFolders(
    CredentialUser user,
    CloudFileType type,
  ) async {
    final response = await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.dataListFolders,
        data: {
          'cognito_group': user.cognitoGroup,
          'username': user.email,
          'log_type': type.apiValue,
        },
        accessToken: user.credential.accessToken,
      ),
    );
    return response['folders'].cast<String>();
  }

  /// Downloads `file` with the [filePath].
  Future<void> requestDownloadFileEmail(
    CredentialUser user,
    String filePath,
  ) async {
    await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.downloadFile,
        data: {'username': user.email, 'file_Path': filePath},
        accessToken: user.credential.accessToken,
      ),
    );
  }

  /// Downloads multi `file` with the [filePaths].
  Future<void> requestDownloadMultiFileEmail(
    CredentialUser user,
    List<String> filePaths,
  ) async {
    await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.dataBulkDownload,
        data: {'username': user.email, 'file_paths': filePaths},
        accessToken: user.credential.accessToken,
      ),
    );
  }

  /// Fetches the upload `URL` with the [sn], [folderPath] and [filename].
  Future<String> _fetchUploadUrl(
    CredentialUser user,
    String sn,
    String folderPath,
    String filename,
  ) async {
    final response = await ApiHelper.post(
      ApiRequest(
        endpoint: ApiHelper.dataUpload,
        data: {
          'username': user.email,
          'folder_path': folderPath,
          'file_name': filename,
          'AdEM_SN': sn,
        },
        accessToken: user.credential.accessToken,
      ),
    );
    return response['url'];
  }

  /// Fetches the `url`, then using this to upload the `file`
  Future<void> uploadFile(
    CredentialUser user,
    String sn,
    String folderPath,
    String filePath,
    String filename,
    ExportFormat fmt,
  ) async {
    final url = await _fetchUploadUrl(user, sn, folderPath, filename);
    final file = File(filePath);

    await ApiHelper.put(
      ApiRequest(
        url: url,
        data: file.openRead(),
        contentType: switch (fmt) {
          ExportFormat.excel => ApiContentType.xlsx,
          ExportFormat.pdf => ApiContentType.pdf,
          ExportFormat.json => ApiContentType.json,
        },
        contentLength: file.lengthSync(),
      ),
    );
  }

  Future<UserCreatedStatus> uploadUsersJson(
    CredentialUser user,
    Map<String, dynamic> file,
  ) async {
    final response = await ApiHelper.post(
      ApiRequest(
        url:
            'https://y1w5f43rx8.execute-api.us-east-1.amazonaws.com/production/user/bulk-create',
        data: file,
        contentType: ApiContentType.json,
        accessToken: user.credential.accessToken,
      ),
    );

    return UserCreatedStatus.fromJson(response);
  }
}
