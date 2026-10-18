import 'package:flutter_test/flutter_test.dart';
import 'package:jaycom_contacts/features/professions/domain/entities/profession.dart';
import 'package:jaycom_contacts/features/professions/domain/repositories/professions_repository.dart';
import 'package:jaycom_contacts/features/professions/presentation/cubit/professions_cubit.dart';
import 'package:jaycom_contacts/features/professions/presentation/cubit/professions_state.dart';

class _FakeProfessionsRepository implements ProfessionsRepository {
  final professions = <Profession>[
    const Profession(id: 1, name: 'سباك'),
    const Profession(id: 2, name: 'نجار'),
  ];

  @override
  Future<void> addProfession(String name) async {
    professions.add(Profession(id: professions.length + 1, name: name));
  }

  @override
  Future<List<Profession>> getProfessions() async =>
      List.unmodifiable(professions);
}

void main() {
  test(
    'adding a profession refreshes the list and selects the new item',
    () async {
      final repository = _FakeProfessionsRepository();
      final cubit = ProfessionsCubit(repository);
      await cubit.fetchProfessions();

      await cubit.addProfession('  حداد  ');

      expect(cubit.state, isA<ProfessionAddSuccess>());
      expect(cubit.state.professions.map((item) => item.name), [
        'سباك',
        'نجار',
        'حداد',
      ]);
      expect(cubit.state.selectedProfession?.name, 'حداد');
      await cubit.close();
    },
  );
}
