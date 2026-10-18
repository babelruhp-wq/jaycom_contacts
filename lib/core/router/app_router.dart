import 'package:go_router/go_router.dart';
import 'package:jaycom_contacts/core/router/router_refresh_notifier.dart';
import 'package:jaycom_contacts/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jaycom_contacts/features/auth/presentation/screens/login_screen.dart';
import 'package:jaycom_contacts/features/contacts/presentation/screens/contacts_dashboard_screen.dart';

class AppRouter {
  AppRouter(AuthCubit authCubit)
    : _refreshNotifier = RouterRefreshNotifier(authCubit.stream) {
    router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _refreshNotifier,
      redirect: (context, state) {
        final authenticated = authCubit.isAuthenticated;
        final atLogin = state.matchedLocation == '/login';
        if (!authenticated && !atLogin) return '/login';
        if (authenticated && atLogin) return '/contacts';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/contacts',
          builder: (context, state) => const ContactsDashboardScreen(),
        ),
      ],
    );
  }

  final RouterRefreshNotifier _refreshNotifier;
  late final GoRouter router;
}
