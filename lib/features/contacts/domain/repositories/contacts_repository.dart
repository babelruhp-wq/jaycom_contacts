import 'package:jaycom_contacts/features/contacts/domain/entities/contact.dart';

abstract interface class ContactsRepository {
  Future<List<Contact>> getContacts();
  Future<void> addContact({required int professionId, required String phone});
}
