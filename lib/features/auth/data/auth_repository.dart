import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/json/json_utils.dart';
import '../../../core/session/session_state.dart';
import '../../../network/dio_provider.dart';

class MePayload {
  const MePayload({required this.userName, required this.factories});

  final String? userName;
  final List<FactoryOption> factories;
}

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
    );

    final data = jsonMap(response.data);
    return firstString(data, const ['token', 'accessToken', 'jwt']);
  }

  Future<MePayload> me() async {
    final response = await _dio.get<dynamic>('/api/auth/me');
    final data = jsonMap(response.data);

    final user = jsonMap(data['user']);
    final userName =
        firstString(user, const ['name', 'fullName', 'email']) ??
        firstString(data, const ['name', 'fullName', 'email']);

    final factoriesRaw =
        data['factories'] ??
        jsonMap(data['data'])['factories'] ??
        jsonMap(data['result'])['factories'];

    final factories = jsonList(factoriesRaw)
        .map(jsonMap)
        .map(
          (raw) => FactoryOption(
            id: firstString(raw, const ['id', 'factoryId', 'uuid']) ?? '',
            name:
                firstString(raw, const ['name', 'factoryName', 'label']) ??
                'Factory',
          ),
        )
        .where((factory) => factory.id.isNotEmpty)
        .toList(growable: false);

    return MePayload(userName: userName, factories: factories);
  }

  Future<void> logout() async {
    await _dio.post<dynamic>('/api/auth/logout');
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(dioProvider)),
);
