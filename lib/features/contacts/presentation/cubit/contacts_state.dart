import 'package:equatable/equatable.dart';
import 'package:jaycom_contacts/features/contacts/domain/entities/contact.dart';

sealed class ContactsState extends Equatable {
  const ContactsState({this.contacts = const [], this.searchQuery = ''});

  final List<Contact> contacts;
  final String searchQuery;

  @override
  List<Object?> get props => [contacts, searchQuery];
}

final class ContactsInitial extends ContactsState {
  const ContactsInitial();
}

final class ContactsLoading extends ContactsState {
  const ContactsLoading({super.contacts, super.searchQuery});
}

final class ContactsLoaded extends ContactsState {
  const ContactsLoaded({required super.contacts, super.searchQuery});
}

final class ContactsError extends ContactsState {
  const ContactsError({
    required this.message,
    super.contacts,
    super.searchQuery,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}

final class ContactsAdding extends ContactsState {
  const ContactsAdding({required super.contacts, super.searchQuery});
}

final class ContactAddSuccess extends ContactsState {
  const ContactAddSuccess({
    required this.phone,
    required super.contacts,
    super.searchQuery,
    this.refreshWarning,
  });

  final String phone;
  final String? refreshWarning;

  @override
  List<Object?> get props => [...super.props, phone, refreshWarning];
}

final class ContactAddFailure extends ContactsState {
  const ContactAddFailure({
    required this.message,
    required super.contacts,
    super.searchQuery,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
