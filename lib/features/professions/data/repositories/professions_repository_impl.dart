import 'package:jaycom_contacts/features/professions/data/datasources/professions_remote_data_source.dart';
import 'package:jaycom_contacts/features/professions/domain/entities/profession.dart';
import 'package:jaycom_contacts/features/professions/domain/repositories/professions_repository.dart';

class ProfessionsRepositoryImpl implements ProfessionsRepository {
  const ProfessionsRepositoryImpl(this._remoteDataSource);

  final ProfessionsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Profession>> getProfessions() =>
      _remoteDataSource.getProfessions();

  @override
  Future<void> addProfession(String name) =>
      _remoteDataSource.addProfession(name);
}
