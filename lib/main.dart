import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jaycom_contacts/core/di/injection_container.dart';
import 'package:jaycom_contacts/core/router/app_router.dart';
import 'package:jaycom_contacts/core/theme/app_theme.dart';
import 'package:jaycom_contacts/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jaycom_contacts/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:jaycom_contacts/features/professions/presentation/cubit/professions_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await configureDependencies();
  runApp(const JaycomContactsApp());
}

class JaycomContactsApp extends StatelessWidget {
  const JaycomContactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthCubit>()),
        BlocProvider.value(value: getIt<ProfessionsCubit>()),
        BlocProvider.value(value: getIt<ContactsCubit>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Jaycom Contacts',
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: getIt<AppRouter>().router,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
