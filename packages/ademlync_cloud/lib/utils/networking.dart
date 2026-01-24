import 'package:ademlync_device/ademlync_device.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

const _connectTimeoutInSec = 30000;
const _duplicatedRequestIntervalInSec = 5;

/// Handles request with `Dio`.
///
/// This method manages `_NetworkRequest` for various `_HttpMethod`:
///
/// * `GET`: Retrieves data from the server.
/// * `POST`: Submits data to be processed by the server.
/// * `PUT`: Updates existing data on the server.
/// * `DELETE`: Removes data from the server.
class Networking {
  static final _instance = Networking._internal();
  factory Networking() => _instance;

  late final Dio _dio;
  final Map<_NetworkRequest, CancelToken> _cancelTokens = {};
  final Map<_NetworkRequest, Future<Response>> _requests = {};

  /// Initiates `Dio` with `connectTimeout`
  Networking._internal() {
    // Init the Dio
    _dio = Dio();

    // Set connection timeout
    _dio.options.connectTimeout = const Duration(seconds: _connectTimeoutInSec);
  }

  /// Performs a `GET` request.
  Future<Response<dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    final request = _NetworkRequest(
      _HttpMethod.get,
      url,
      queryParameters: queryParameters,
    );
    return _request(request, options);
  }

  /// Performs a `POST` request.
  Future<Response<dynamic>> post(String url, {Object? data, Options? options}) {
    final request = _NetworkRequest(_HttpMethod.post, url, data: data);
    return _request(request, options);
  }

  /// Performs a `PUT` request.
  Future<Response<dynamic>> put(String url, {Object? data, Options? options}) {
    final request = _NetworkRequest(_HttpMethod.put, url, data: data);
    return _request(request, options);
  }

  /// Performs a `DELETE` request.
  Future<Response<dynamic>> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
  }) {
    final request = _NetworkRequest(
      _HttpMethod.delete,
      url,
      queryParameters: queryParameters,
      data: data,
    );
    return _request(request, options);
  }

  /// Handles request asynchronously.
  ///
  /// This method manages `_NetworkRequest` in two scenarios:
  ///
  /// * Case 1: Continues with a cached request if a duplicate is detected within `_duplicatedRequestIntervalInSec`.
  /// * Case 2: Creates and executes a new request if no cached request is available.
  ///
  /// Returns `Response` if available.
  ///
  /// Throws `Exception` if error is caught; otherwise, Throws `Unknown Exception` if `Response` is not available.
  Future<Response<dynamic>> _request(
    _NetworkRequest request,
    Options? options,
  ) async {
    Response<dynamic>? res;
    Object? error;

    // Determine any duplicate request
    final duplicate = _requests.keys.firstWhereOrNull((e) => e == request);

    // Duplicated request found
    if (duplicate != null) {
      // Determine the request time difference
      final timeDiffInSec = duplicate.dateTime
          .difference(request.dateTime)
          .inSeconds;

      // Pick this duplicated request
      if (timeDiffInSec < _duplicatedRequestIntervalInSec) {
        try {
          // Wait for the request to finish
          res = await _requests[duplicate];
        } catch (e) {
          error = e;
        }
      } else {
        _cancelTokens[duplicate]?.cancel();
      }
    }

    // There is no duplicated request
    if (res == null && error == null) {
      // Create a cancel token
      final cancelToken = CancelToken();

      // Set the http method
      options = (options ??= Options()).copyWith(method: request.method.string);

      // Create the request Future func
      final response = _dio.request(
        request.url,
        queryParameters: request.queryParameters,
        data: request.data,
        options: options,
        cancelToken: cancelToken,
      );

      //Store as a ref to determine duplicates
      _cancelTokens[request] = cancelToken;
      _requests[request] = response;

      try {
        // Wait for the request to finish
        res = await response;
      } catch (e) {
        error = e;
      }

      // Remove the ref
      _cancelTokens.remove(request);
      _requests.remove(request);
    }

    // Determine the response is valid
    if (res != null && error == null) {
      return res;
    } else {
      throw error ?? Exception('Unknown');
    }
  }
}

class _NetworkRequest extends Equatable {
  final DateTime dateTime = DateTime.now();
  final _HttpMethod method;
  final String url;
  final Map<String, dynamic>? queryParameters;
  final Object? data;

  _NetworkRequest(this.method, this.url, {this.queryParameters, this.data});

  @override
  List<Object?> get props => [dateTime, method, url, queryParameters, data];
}

enum _HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  final String string;

  const _HttpMethod(this.string);
}
