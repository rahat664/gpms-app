import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../core/session/request_context.dart';

final cookieJarProvider = Provider<CookieJar>((ref) => CookieJar());

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final context = ref.read(requestContextProvider);
  final cookieJar = ref.read(cookieJarProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const <String, String>{'Accept': 'application/json'},
      contentType: 'application/json',
      responseType: ResponseType.json,
      extra: const <String, dynamic>{'withCredentials': true},
    ),
  );

  dio.interceptors.add(CookieManager(cookieJar));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['withCredentials'] = true;

        final factoryId = context.factoryId;
        if (factoryId != null && factoryId.isNotEmpty) {
          options.headers['x-factory-id'] = factoryId;
        }

        if (config.useTokenAuth) {
          final token = context.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        handler.next(options);
      },
    ),
  );

  return dio;
});
