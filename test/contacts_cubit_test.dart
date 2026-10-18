import 'package:flutter_test/flutter_test.dart';
import 'package:jaycom_contacts/features/contacts/domain/entities/contact.dart';
import 'package:jaycom_contacts/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:jaycom_contacts/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:jaycom_contacts/features/contacts/presentation/cubit/contacts_state.dart';

class _FakeContactsRepository implements ContactsRepository {
  final contacts = <Contact>[];
  int addCalls = 0;

  @override
  Future<void> addContact({
    required int professionId,
    required String phone,
  }) async {
    addCalls += 1;
    contacts.add(
      Contact(
        id: contacts.length + 1,
        professionId: professionId,
        professionName: 'نجار',
        phone: phone,
      ),
    );
  }

  @override
  Future<List<Contact>> getContacts() async => List.unmodifiable(contacts);
}

void main() {
  test(
    'adding a contact posts the composed number and refreshes contacts',
    () async {
      final repository = _FakeContactsRepository();
      final cubit = ContactsCubit(repository);

      await cubit.addContact(
        professionId: 2,
        professionName: 'نجار',
        localNumber: '0545365521',
      );

      expect(repository.addCalls, 1);
      expect(cubit.state, isA<ContactAddSuccess>());
      expect(cubit.state.contacts.single.phone, '+966545365521');
      await cubit.close();
    },
  );

  test('duplicate in the same profession is rejected before posting', () async {
    final repository = _FakeContactsRepository()
      ..contacts.add(
        const Contact(
          id: 1,
          professionId: 2,
          professionName: 'نجار',
          phone: '+966545365521',
        ),
      );
    final cubit = ContactsCubit(repository);
    await cubit.fetchContacts();

    await cubit.addContact(
      professionId: 2,
      professionName: 'نجار',
      localNumber: '0545365521',
    );

    expect(repository.addCalls, 0);
    expect(cubit.state, isA<ContactAddFailure>());
    await cubit.close();
  });
}
