enum SessionStatus { initial, loading, unauthenticated, needsFactory, ready }

class FactoryOption {
  const FactoryOption({required this.id, required this.name});

  final String id;
  final String name;
}

class SessionState {
  const SessionState({
    this.status = SessionStatus.initial,
    this.token,
    this.userName,
    this.factories = const <FactoryOption>[],
    this.activeFactoryId,
    this.errorMessage,
  });

  final SessionStatus status;
  final String? token;
  final String? userName;
  final List<FactoryOption> factories;
  final String? activeFactoryId;
  final String? errorMessage;

  bool get isAuthenticated =>
      status == SessionStatus.needsFactory || status == SessionStatus.ready;

  SessionState copyWith({
    SessionStatus? status,
    String? token,
    String? userName,
    List<FactoryOption>? factories,
    String? activeFactoryId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      token: token ?? this.token,
      userName: userName ?? this.userName,
      factories: factories ?? this.factories,
      activeFactoryId: activeFactoryId ?? this.activeFactoryId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
