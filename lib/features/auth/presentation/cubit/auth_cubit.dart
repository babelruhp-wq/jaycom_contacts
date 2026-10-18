import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaycom_contacts/core/constants/app_constants.dart';
import 'package:jaycom_contacts/features/auth/domain/repositories/auth_session_repository.dart';
import 'package:jaycom_contacts/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._sessionRepository)
    : super(
        _sessionRepository.hasActiveSession
            ? const AuthAuthenticated()
            : const AuthInitial(),
      );

  final AuthSessionRepository _sessionRepository;

  bool get isAuthenticated => state is AuthAuthenticated;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (username.trim() == AppConstants.loginUsername &&
        password == AppConstants.loginPassword) {
      try {
        await _sessionRepository.persistSession();
        emit(const AuthAuthenticated());
      } catch (_) {
        emit(
          const AuthError(
            'بيانات الدخول صحيحة، لكن تعذر حفظ الجلسة. حاول مرة أخرى.',
          ),
        );
      }
      return;
    }
    emit(const AuthError('اسم المستخدم أو كلمة المرور غير صحيحة.'));
  }

  Future<void> logout() async {
    try {
      await _sessionRepository.clearSession();
    } finally {
      emit(const AuthLoggedOut());
    }
  }
}
