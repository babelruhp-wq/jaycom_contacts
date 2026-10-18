import 'package:jaycom_contacts/features/auth/domain/repositories/auth_session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionRepositoryImpl implements AuthSessionRepository {
  const AuthSessionRepositoryImpl(this._preferences);

  static const _sessionKey = 'jaycom_local_session_active';

  final SharedPreferences _preferences;

  @override
  bool get hasActiveSession => _preferences.getBool(_sessionKey) ?? false;

  @override
  Future<void> persistSession() async {
    await _preferences.setBool(_sessionKey, true);
  }

  @override
  Future<void> clearSession() async {
    await _preferences.remove(_sessionKey);
  }
}
