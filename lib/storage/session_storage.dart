import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _tokenKey = 'auth_token';
  static const _factoryIdKey = 'factory_id';

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> readFactoryId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_factoryIdKey);
  }

  Future<void> writeToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_tokenKey);
      return;
    }
    await prefs.setString(_tokenKey, token);
  }

  Future<void> writeFactoryId(String? factoryId) async {
    final prefs = await SharedPreferences.getInstance();
    if (factoryId == null || factoryId.isEmpty) {
      await prefs.remove(_factoryIdKey);
      return;
    }
    await prefs.setString(_factoryIdKey, factoryId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_factoryIdKey);
  }
}

final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => SessionStorage(),
);
