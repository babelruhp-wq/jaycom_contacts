import 'package:jaycom_contacts/features/contacts/domain/entities/contact.dart';
import 'package:jaycom_contacts/features/contacts/domain/utils/contact_matcher.dart';

abstract final class ContactsCsvExporter {
  static String forProfession({
    required Iterable<Contact> contacts,
    required String professionName,
  }) {
    final selected = contactsForProfession(contacts, professionName);
    return _buildCsv(selected);
  }

  static String forAllProfessions(Iterable<Contact> contacts) {
    return _buildCsv(contacts);
  }

  static String phoneWithoutPlus(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String safeFilePart(String value) {
    final cleaned = value
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.isEmpty ? 'contacts' : cleaned;
  }

  static String _buildCsv(Iterable<Contact> contacts) {
    return contacts
        .map((contact) => phoneWithoutPlus(contact.phone))
        .join('\r\n');
  }
}
