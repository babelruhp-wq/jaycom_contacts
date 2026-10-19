import 'package:flutter_test/flutter_test.dart';
import 'package:jaycom_contacts/features/contacts/domain/entities/contact.dart';
import 'package:jaycom_contacts/features/contacts/domain/utils/contacts_csv_exporter.dart';

void main() {
  const contacts = [
    Contact(id: 1, professionName: 'نجار', phone: '+966545365521'),
    Contact(id: 2, professionName: 'سباك', phone: '+966500000001'),
    Contact(id: 3, professionName: '  نجار  ', phone: '+966511111111'),
  ];

  test('exports one profession and removes the plus sign from full phones', () {
    final csv = ContactsCsvExporter.forProfession(
      contacts: contacts,
      professionName: 'نجار',
    );

    expect(csv, '966545365521\r\n966511111111');
  });

  test('exports all professions in API contact order', () {
    final csv = ContactsCsvExporter.forAllProfessions(contacts);

    expect(csv, '966545365521\r\n966500000001\r\n966511111111');
  });

  test('each exported row contains digits only', () {
    final csv = ContactsCsvExporter.forAllProfessions(contacts);

    expect(
      csv.split('\r\n').every((row) => RegExp(r'^[0-9]+$').hasMatch(row)),
      isTrue,
    );
    expect(csv, isNot(contains(',')));
    expect(csv, isNot(contains('+')));
    expect(csv, isNot(contains('\uFEFF')));
  });

  test('keeps the profession name readable in the downloaded file name', () {
    expect(ContactsCsvExporter.safeFilePart('  فني   تكييف  '), 'فني تكييف');
  });
}
