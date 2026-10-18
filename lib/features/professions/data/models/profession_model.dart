import 'package:jaycom_contacts/features/professions/domain/entities/profession.dart';

class ProfessionModel extends Profession {
  const ProfessionModel({required super.id, required super.name});

  factory ProfessionModel.fromJson(Map<String, dynamic> json) {
    return ProfessionModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String? ?? '').trim(),
    );
  }
}
