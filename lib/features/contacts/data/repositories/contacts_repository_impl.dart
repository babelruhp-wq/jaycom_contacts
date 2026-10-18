import 'package:jaycom_contacts/features/contacts/data/datasources/contacts_remote_data_source.dart';
import 'package:jaycom_contacts/features/contacts/domain/entities/contact.dart';
import 'package:jaycom_contacts/features/contacts/domain/repositories/contacts_repository.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  const ContactsRepositoryImpl(this._remoteDataSource);

  final ContactsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Contact>> getContacts() => _remoteDataSource.getContacts();

  @override
  Future<void> addContact({required int professionId, required String phone}) {
    return _remoteDataSource.addContact(
      professionId: professionId,
      phone: phone,
    );
  }
}
