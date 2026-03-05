import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.useTokenAuth});

  final String apiBaseUrl;
  final bool useTokenAuth;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  final env = dotenv.env;
  final apiBaseUrl = (env['API_BASE_URL'] ?? '').trim().isEmpty
      ? 'https://clever-serenity-production.up.railway.app'
      : env['API_BASE_URL']!.trim();
  final useTokenAuth =
      (env['USE_TOKEN_AUTH'] ?? 'false').toLowerCase() == 'true';

  return AppConfig(apiBaseUrl: apiBaseUrl, useTokenAuth: useTokenAuth);
});
