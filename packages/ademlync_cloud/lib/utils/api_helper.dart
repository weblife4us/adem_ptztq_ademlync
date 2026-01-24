import 'package:dio/dio.dart';
import 'package:sprintf/sprintf.dart';

import 'enums.dart';
import 'error_enum.dart';
import 'networking.dart';

const _host = 'y1w5f43rx8.execute-api.us-east-1.amazonaws.com';
const _apiVersion = '/production';

/// Manages API request.
///
/// This method handles `ApiRequest` objects for various `_HttpMethod`s:
/// * It stores the endpoint.
/// * Generates request `Options`.
/// * Processes `Response` from the `ApiRequest`.
class ApiHelper {
  static final _networking = Networking();

  // End points
  static const signIn = '/sign-in';
  static const userCreate = '/user/create';
  static const userDelete = '/user/delete';
  static const userModify = '/user/modify';
  static const userList = '/user/list';
  static const userGroup = '/user/groups';
  static const userForgotPassword = '/user/forgot-password';
  static const userConfirmForgotPassword = '/user/confirm-forgot-password';
  static const dataUpload = '/data/upload';

  static const discoverIdp = '/discover-idp';

  static const getMfaStatus = '/get-mfa-status';
  static const enableMfa = '/enable-mfa';
  static const verifyMfa = '/verify-mfa';
  static const mfaChallenge = '/mfa-challenge';

  /// Single file download.
  static const downloadFile = '/download-file';

  /// Multi files download.
  static const dataBulkDownload = '/data/bulk-download';
  static const dataListFiles = '/data/list-files';
  static const dataListFolders = '/data/list-folders';

  /// Performs a `GET` request.
  static Future<dynamic> get(ApiRequest request) async {
    return await _responseWith(
      _networking.get(
        request.uriString,
        queryParameters: request.queryParams,
        options: options(request),
      ),
    );
  }

  /// Performs a `POST` request.
  static Future<dynamic> post(ApiRequest request) async {
    return await _responseWith(
      _networking.post(
        request.uriString,
        data: request.data,
        options: options(request),
      ),
    );
  }

  /// Performs a `PUT` request.
  static Future<dynamic> put(ApiRequest request) async {
    return await _responseWith(
      _networking.put(
        request.uriString,
        data: request.data,
        options: options(request),
      ),
    );
  }

  /// Performs a `DELETE` request.
  static Future<dynamic> delete(ApiRequest request) async {
    return await _responseWith(
      _networking.delete(
        request.uriString,
        queryParameters: request.queryParams,
        data: request.data,
        options: options(request),
      ),
    );
  }

  /// Generates `Options` based on the provided [ApiRequest].
  static Options? options(ApiRequest request) {
    final ApiRequest(:accessToken, :contentType, :contentLength, :data) =
        request;
    Options? res;

    // Determine the necessity of Options
    if ([accessToken, contentType, contentLength, data].any((e) => e != null)) {
      res = Options(
        headers: {
          // Set the access token
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',

          if (contentType != null)
            // Set the custom content type
            'Content-Type': contentType.key
          else if (data != null)
            // Set the json content type
            'Content-Type': ApiContentType.json.key,

          // Set the content length
          if (contentLength != null) 'Content-Length': contentLength.toString(),
        },
      );
    }

    return res;
  }

  /// Processes response from the API request.
  ///
  /// This method handles `Response` received from `ApiRequest`.
  /// If the `response.statusCode` is `200`, it returns `Response`.
  /// Otherwise, it throws an `ApiHelperError` with the `ApiHelperErrorType`
  static Future<dynamic> _responseWith(
    Future<Response<dynamic>> request,
  ) async {
    try {
      // Wait for the request to finish
      final response = await request;

      // Determine if the response is valid
      if (response.statusCode == 200) {
        dynamic res;
        final data = response.data;

        // NOTE: An additional `statusCode` field is present in the API response!!!
        if (data case {'statusCode': int code, 'body': dynamic body}) {
          if (code == 404) {
            throw ApiHelperError(ApiHelperErrorType.responseError, data);
          } else {
            res = body;
          }
        }

        return res;
      } else {
        throw ApiHelperError(ApiHelperErrorType.unknown, response.data);
      }
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      ApiHelperErrorType? type;

      if (code == 401) {
        type = ApiHelperErrorType.unauthorized;
      } else if (code == 403) {
        type = ApiHelperErrorType.unauthorized;
      } else {
        rethrow;
      }

      throw ApiHelperError(type, e.requestOptions);
    }
  }
}

class ApiRequest {
  final String? endpoint;
  final String? url;
  final List<String>? pathParams;
  final Map<String, dynamic>? queryParams;
  final Object? data;
  final String? accessToken;
  final ApiContentType? contentType;
  final int? contentLength;

  /// Generates the full endpoint path with `pathParams`.
  String get endpointPath =>
      pathParams == null ? endpoint! : sprintf(endpoint!, pathParams!);

  /// Generates the full URI for the `ApiRequest`.
  Uri get uri => Uri.https(_host, '$_apiVersion$endpointPath');

  /// Returns the URI string representation.
  String get uriString => url ?? uri.toString();

  ApiRequest({
    this.endpoint,
    this.url,
    this.pathParams,
    this.queryParams,
    this.data,
    this.accessToken,
    this.contentType,
    this.contentLength,
  }) : assert(endpoint != null || url != null, 'endpoint/url can not be null.');
}
