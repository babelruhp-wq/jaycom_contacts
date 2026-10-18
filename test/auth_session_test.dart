import 'package:flutter_test/flutter_test.dart';
import 'package:jaycom_contacts/features/auth/data/repositories/auth_session_repository_impl.dart';
import 'package:jaycom_contacts/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jaycom_contacts/features/auth/presentation/cubit/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('successful login persists until the user logs out', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = AuthSessionRepositoryImpl(preferences);
    final firstCubit = AuthCubit(repository);

    await firstCubit.login(username: 'jaycom', password: '246810');

    expect(firstCubit.state, isA<AuthAuthenticated>());
    expect(repository.hasActiveSession, isTrue);
    await firstCubit.close();

    final restoredCubit = AuthCubit(repository);
    expect(restoredCubit.state, isA<AuthAuthenticated>());

    await restoredCubit.logout();
    expect(restoredCubit.state, isA<AuthLoggedOut>());
    expect(repository.hasActiveSession, isFalse);
    await restoredCubit.close();
  });
}
