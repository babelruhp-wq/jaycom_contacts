import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaycom_contacts/core/errors/app_exception.dart';
import 'package:jaycom_contacts/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:jaycom_contacts/features/contacts/domain/utils/contact_matcher.dart';
import 'package:jaycom_contacts/features/contacts/domain/utils/phone_validator.dart';
import 'package:jaycom_contacts/features/contacts/presentation/cubit/contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit(this._repository) : super(const ContactsInitial());

  final ContactsRepository _repository;

  Future<void> fetchContacts() async {
    if (state is ContactsLoading) return;
    emit(
      ContactsLoading(contacts: state.contacts, searchQuery: state.searchQuery),
    );
    try {
      final contacts = await _repository.getContacts();
      emit(ContactsLoaded(contacts: contacts, searchQuery: state.searchQuery));
    } catch (error) {
      emit(
        ContactsError(
          message: readableError(error),
          contacts: state.contacts,
          searchQuery: state.searchQuery,
        ),
      );
    }
  }

  void updateSearch(String query) {
    emit(ContactsLoaded(contacts: state.contacts, searchQuery: query));
  }

  void clearSearch() {
    if (state.searchQuery.isEmpty) return;
    emit(ContactsLoaded(contacts: state.contacts));
  }

  Future<void> addContact({
    required int professionId,
    required String professionName,
    required String localPart,
  }) async {
    if (state is ContactsAdding) return;
    if (!PhoneValidator.isValidLocalPart(localPart)) {
      emit(
        ContactAddFailure(
          message: 'يجب أن يتكون الرقم من 8 أرقام إنجليزية.',
          contacts: state.contacts,
          searchQuery: state.searchQuery,
        ),
      );
      return;
    }

    final phone = PhoneValidator.buildFullPhone(localPart);
    if (contactExistsInProfession(
      contacts: state.contacts,
      professionName: professionName,
      phone: phone,
    )) {
      emit(
        ContactAddFailure(
          message: 'رقم الهاتف مسجل بالفعل ضمن هذه المهنة.',
          contacts: state.contacts,
          searchQuery: state.searchQuery,
        ),
      );
      return;
    }

    final previousContacts = state.contacts;
    final previousSearch = state.searchQuery;
    emit(
      ContactsAdding(contacts: previousContacts, searchQuery: previousSearch),
    );
    try {
      await _repository.addContact(professionId: professionId, phone: phone);
      try {
        final refreshed = await _repository.getContacts();
        emit(
          ContactAddSuccess(
            phone: phone,
            contacts: refreshed,
            searchQuery: previousSearch,
          ),
        );
      } catch (_) {
        emit(
          ContactAddSuccess(
            phone: phone,
            contacts: previousContacts,
            searchQuery: previousSearch,
            refreshWarning: 'تمت الإضافة، لكن تعذر تحديث القائمة تلقائيًا.',
          ),
        );
      }
    } catch (error) {
      emit(
        ContactAddFailure(
          message: readableError(error),
          contacts: previousContacts,
          searchQuery: previousSearch,
        ),
      );
    }
  }
}
