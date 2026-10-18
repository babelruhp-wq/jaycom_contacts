import 'package:jaycom_contacts/features/professions/domain/entities/profession.dart';

abstract interface class ProfessionsRepository {
  Future<List<Profession>> getProfessions();
  Future<void> addProfession(String name);
}
