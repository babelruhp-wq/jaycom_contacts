abstract interface class AuthSessionRepository {
  bool get hasActiveSession;

  Future<void> persistSession();

  Future<void> clearSession();
}
