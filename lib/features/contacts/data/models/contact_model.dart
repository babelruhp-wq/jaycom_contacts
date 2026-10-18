import 'package:jaycom_contacts/features/contacts/domain/entities/contact.dart';

class ContactModel extends Contact {
  const ContactModel({
    required super.id,
    required super.professionName,
    required super.phone,
    super.professionId,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    final rawProfessionId = json['professionId'];
    return ContactModel(
      id: (json['id'] as num).toInt(),
      professionName: (json['professionName'] as String? ?? '').trim(),
      phone: (json['phone'] as String? ?? '').trim(),
      professionId: rawProfessionId is num ? rawProfessionId.toInt() : null,
    );
  }
}
