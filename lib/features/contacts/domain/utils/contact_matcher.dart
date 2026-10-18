import 'package:jaycom_contacts/features/contacts/domain/entities/contact.dart';

String normalizeComparableText(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

List<Contact> contactsForProfession(
  Iterable<Contact> contacts,
  String professionName, {
  String query = '',
}) {
  final normalizedProfession = normalizeComparableText(professionName);
  final normalizedQuery = query.trim().replaceAll(' ', '');
  return contacts
      .where((contact) {
        final sameProfession =
            normalizeComparableText(contact.professionName) ==
            normalizedProfession;
        final matchesSearch =
            normalizedQuery.isEmpty ||
            contact.phone.replaceAll(' ', '').contains(normalizedQuery);
        return sameProfession && matchesSearch;
      })
      .toList(growable: false);
}

bool contactExistsInProfession({
  required Iterable<Contact> contacts,
  required String professionName,
  required String phone,
}) {
  final normalizedPhone = phone.trim().replaceAll(' ', '');
  return contactsForProfession(contacts, professionName).any(
    (contact) => contact.phone.trim().replaceAll(' ', '') == normalizedPhone,
  );
}
