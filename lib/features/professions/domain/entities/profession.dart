import 'package:equatable/equatable.dart';

class Profession extends Equatable {
  const Profession({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
