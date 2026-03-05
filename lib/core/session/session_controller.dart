import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../storage/session_storage.dart';
import 'request_context.dart';
import 'session_state.dart';

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>(
      (ref) => SessionController(
        ref,
        authRepository: ref.read(authRepositoryProvider),
        storage: ref.read(sessionStorageProvider),
      ),
    );

class SessionController extends StateNotifier<SessionState> {
  SessionController(
    this._ref, {
    required AuthRepository authRepository,
    required SessionStorage storage,
  }) : _authRepository = authRepository,
       _storage = storage,
       super(const SessionState());

  final Ref _ref;
  final AuthRepository _authRepository;
  final SessionStorage _storage;

  Future<SessionState> bootstrap() async {
    state = state.copyWith(status: SessionStatus.loading, clearError: true);

    final token = await _storage.readToken();
    final savedFactoryId = await _storage.readFactoryId();
    _syncRequestContext(token: token, factoryId: savedFactoryId);

    try {
      final me = await _authRepository.me();
      final activeFactoryId = _pickFactoryId(savedFactoryId, me.factories);

      _syncRequestContext(token: token, factoryId: activeFactoryId);

      state = state.copyWith(
        status: activeFactoryId == null
            ? SessionStatus.needsFactory
            : SessionStatus.ready,
        token: token,
        userName: me.userName,
        factories: me.factories,
        activeFactoryId: activeFactoryId,
        clearError: true,
      );
      return state;
    } catch (_) {
      await _storage.clear();
      _syncRequestContext(token: null, factoryId: null);
      state = const SessionState(status: SessionStatus.unauthenticated);
      return state;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: SessionStatus.loading, clearError: true);
    try {
      final token = await _authRepository.login(
        email: email,
        password: password,
      );
      await _storage.writeToken(token);
      _syncRequestContext(token: token, factoryId: state.activeFactoryId);

      final postLoginState = await bootstrap();
      return postLoginState.status != SessionStatus.unauthenticated;
    } catch (_) {
      state = state.copyWith(
        status: SessionStatus.unauthenticated,
        errorMessage: 'Login failed. Please check credentials and try again.',
      );
      return false;
    }
  }

  Future<void> selectFactory(String factoryId) async {
    await _storage.writeFactoryId(factoryId);
    _syncRequestContext(token: state.token, factoryId: factoryId);

    state = state.copyWith(
      status: SessionStatus.ready,
      activeFactoryId: factoryId,
    );
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (_) {
      // Ignore network logout failures and clear local session anyway.
    }

    await _storage.clear();
    _syncRequestContext(token: null, factoryId: null);
    state = const SessionState(status: SessionStatus.unauthenticated);
  }

  String? _pickFactoryId(String? storedId, List<FactoryOption> factories) {
    if (factories.isEmpty) return null;
    if (storedId == null || storedId.isEmpty) return factories.first.id;
    final exists = factories.any((factory) => factory.id == storedId);
    return exists ? storedId : factories.first.id;
  }

  void _syncRequestContext({String? token, String? factoryId}) {
    final requestContext = _ref.read(requestContextProvider);
    requestContext.token = token;
    requestContext.factoryId = factoryId;
  }
}
