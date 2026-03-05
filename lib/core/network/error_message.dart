import 'package:dio/dio.dart';

import '../json/json_utils.dart';

String readableErrorMessage(
  Object error, {
  String fallback = 'Request failed',
}) {
  if (error is DioException) {
    final data = error.response?.data;
    final map = jsonMap(data);
    final message =
        firstString(map, const <String>['message', 'error', 'detail']) ??
        firstString(jsonMap(map['data']), const <String>['message']) ??
        error.message;
    if (message != null && message.trim().isNotEmpty) {
      return message.trim();
    }
  }

  final value = error.toString();
  if (value.isNotEmpty) return value;
  return fallback;
}
