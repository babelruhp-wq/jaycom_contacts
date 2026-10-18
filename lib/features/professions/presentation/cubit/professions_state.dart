import 'package:equatable/equatable.dart';
import 'package:jaycom_contacts/features/professions/domain/entities/profession.dart';

sealed class ProfessionsState extends Equatable {
  const ProfessionsState({
    this.professions = const [],
    this.selectedProfession,
  });

  final List<Profession> professions;
  final Profession? selectedProfession;

  @override
  List<Object?> get props => [professions, selectedProfession];
}

final class ProfessionsInitial extends ProfessionsState {
  const ProfessionsInitial();
}

final class ProfessionsLoading extends ProfessionsState {
  const ProfessionsLoading({super.professions, super.selectedProfession});
}

final class ProfessionsLoaded extends ProfessionsState {
  const ProfessionsLoaded({
    required super.professions,
    required super.selectedProfession,
  });
}

final class ProfessionsError extends ProfessionsState {
  const ProfessionsError({
    required this.message,
    super.professions,
    super.selectedProfession,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}

final class ProfessionsAdding extends ProfessionsState {
  const ProfessionsAdding({
    required super.professions,
    required super.selectedProfession,
  });
}

final class ProfessionAddSuccess extends ProfessionsState {
  const ProfessionAddSuccess({
    required this.addedProfession,
    required super.professions,
    required super.selectedProfession,
  });

  final Profession addedProfession;

  @override
  List<Object?> get props => [...super.props, addedProfession];
}

final class ProfessionAddFailure extends ProfessionsState {
  const ProfessionAddFailure({
    required this.message,
    required super.professions,
    required super.selectedProfession,
  });

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
