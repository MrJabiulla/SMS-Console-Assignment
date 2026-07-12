import '../error/app_failure.dart';

class ApiResult<T> {
  const ApiResult({this.data, required this.statusCode, this.failure});

  final T? data;
  final int statusCode;
  final AppFailure? failure;
}
