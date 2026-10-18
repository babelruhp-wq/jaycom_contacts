import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaycom_contacts/core/errors/app_exception.dart';
import 'package:jaycom_contacts/features/professions/domain/entities/profession.dart';
import 'package:jaycom_contacts/features/professions/domain/repositories/professions_repository.dart';
import 'package:jaycom_contacts/features/professions/presentation/cubit/professions_state.dart';

class ProfessionsCubit extends Cubit<ProfessionsState> {
  ProfessionsCubit(this._repository) : super(const ProfessionsInitial());

  final ProfessionsRepository _repository;

  Future<void> fetchProfessions() async {
    if (state is ProfessionsLoading) return;
    emit(
      ProfessionsLoading(
        professions: state.professions,
        selectedProfession: state.selectedProfession,
      ),
    );
    try {
      final professions = await _repository.getProfessions();
      final selected =
          _retainSelection(professions) ??
          (professions.isEmpty ? null : professions.first);
      emit(
        ProfessionsLoaded(
          professions: professions,
          selectedProfession: selected,
        ),
      );
    } catch (error) {
      emit(
        ProfessionsError(
          message: readableError(error),
          professions: state.professions,
          selectedProfession: state.selectedProfession,
        ),
      );
    }
  }

  void selectProfession(Profession profession) {
    if (state.selectedProfession?.id == profession.id) return;
    emit(
      ProfessionsLoaded(
        professions: state.professions,
        selectedProfession: profession,
      ),
    );
  }

  Future<void> addProfession(String rawName) async {
    if (state is ProfessionsAdding) return;
    final name = normalizeProfessionName(rawName);
    if (name.isEmpty) {
      emit(
        ProfessionAddFailure(
          message: 'أدخل اسم المهنة.',
          professions: state.professions,
          selectedProfession: state.selectedProfession,
        ),
      );
      return;
    }

    emit(
      ProfessionsAdding(
        professions: state.professions,
        selectedProfession: state.selectedProfession,
      ),
    );
    try {
      await _repository.addProfession(name);
      final professions = await _repository.getProfessions();
      final matching = professions
          .where((item) => normalizeProfessionName(item.name) == name)
          .toList(growable: false);
      final added = matching.isNotEmpty
          ? matching.last
          : (professions.isNotEmpty ? professions.last : null);
      if (added == null) {
        throw const AppException(
          'تمت الإضافة، لكن تعذر العثور على المهنة الجديدة.',
        );
      }
      emit(
        ProfessionAddSuccess(
          addedProfession: added,
          professions: professions,
          selectedProfession: added,
        ),
      );
    } catch (error) {
      emit(
        ProfessionAddFailure(
          message: readableError(error),
          professions: state.professions,
          selectedProfession: state.selectedProfession,
        ),
      );
    }
  }

  Profession? _retainSelection(List<Profession> professions) {
    final id = state.selectedProfession?.id;
    if (id == null) return null;
    for (final profession in professions) {
      if (profession.id == id) return profession;
    }
    return null;
  }
}

String normalizeProfessionName(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
