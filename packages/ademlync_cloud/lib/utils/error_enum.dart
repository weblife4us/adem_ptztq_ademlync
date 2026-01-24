enum ApiHelperErrorType { unauthorized, accessDenied, responseError, unknown }

class ApiHelperError implements Exception {
  final ApiHelperErrorType type;
  final dynamic detail;

  const ApiHelperError(this.type, this.detail);
}
