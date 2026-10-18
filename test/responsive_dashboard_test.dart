import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaycom_contacts/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jaycom_contacts/features/auth/domain/repositories/auth_session_repository.dart';
import 'package:jaycom_contacts/features/contacts/domain/entities/contact.dart';
import 'package:jaycom_contacts/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:jaycom_contacts/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:jaycom_contacts/features/contacts/presentation/screens/contacts_dashboard_screen.dart';
import 'package:jaycom_contacts/features/professions/domain/entities/profession.dart';
import 'package:jaycom_contacts/features/professions/domain/repositories/professions_repository.dart';
import 'package:jaycom_contacts/features/professions/presentation/cubit/professions_cubit.dart';

class _ProfessionsRepository implements ProfessionsRepository {
  @override
  Future<void> addProfession(String name) async {}

  @override
  Future<List<Profession>> getProfessions() async => const [
    Profession(id: 1, name: 'نجار'),
    Profession(id: 2, name: 'سباك'),
  ];
}

class _AuthSessionRepository implements AuthSessionRepository {
  @override
  bool get hasActiveSession => false;

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> persistSession() async {}
}

class _ContactsRepository implements ContactsRepository {
  @override
  Future<void> addContact({
    required int professionId,
    required String phone,
  }) async {}

  @override
  Future<List<Contact>> getContacts() async => const [
    Contact(id: 1, professionName: 'نجار', phone: '+966545365521'),
  ];
}

void main() {
  Future<void> pumpDashboard(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authCubit = AuthCubit(_AuthSessionRepository());
    final professionsCubit = ProfessionsCubit(_ProfessionsRepository());
    final contactsCubit = ContactsCubit(_ContactsRepository());
    addTearDown(authCubit.close);
    addTearDown(professionsCubit.close);
    addTearDown(contactsCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider.value(value: professionsCubit),
          BlocProvider.value(value: contactsCubit),
        ],
        child: const MaterialApp(
          locale: Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: ContactsDashboardScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard lays out without overflow on mobile', (tester) async {
    await pumpDashboard(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);
    expect(find.text('نجار'), findsOneWidget);
    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
  });

  testWidgets('dashboard lays out without overflow on desktop', (tester) async {
    await pumpDashboard(tester, const Size(1280, 800));
    expect(tester.takeException(), isNull);
    expect(find.text('المهن'), findsOneWidget);
    expect(find.text('+966545365521'), findsOneWidget);
    expect(find.byKey(const ValueKey('profession-count-1')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('profession-count-1')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });
}
