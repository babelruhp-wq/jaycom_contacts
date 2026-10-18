import 'package:flutter_test/flutter_test.dart';
import 'package:jaycom_contacts/features/contacts/domain/entities/contact.dart';
import 'package:jaycom_contacts/features/contacts/domain/utils/contact_matcher.dart';

void main() {
  const contacts = [
    Contact(id: 1, professionName: '  نجار  ', phone: '+966545365521'),
    Contact(id: 2, professionName: 'سباك', phone: '+966545365521'),
    Contact(id: 3, professionName: 'نجار', phone: '+966500000001'),
  ];

  test('matches profession names after normalizing spaces', () {
    final result = contactsForProfession(contacts, 'نجار');
    expect(result.map((contact) => contact.id), [1, 3]);
  });

  test('searches only inside the chosen profession', () {
    final result = contactsForProfession(contacts, 'نجار', query: '4536');
    expect(result.map((contact) => contact.id), [1]);
  });

  test('duplicate check is scoped to the profession', () {
    expect(
      contactExistsInProfession(
        contacts: contacts,
        professionName: 'نجار',
        phone: '+966545365521',
      ),
      isTrue,
    );
    expect(
      contactExistsInProfession(
        contacts: contacts,
        professionName: 'حداد',
        phone: '+966545365521',
      ),
      isFalse,
    );
  });
}
