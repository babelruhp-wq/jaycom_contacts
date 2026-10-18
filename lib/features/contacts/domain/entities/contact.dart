import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  const Contact({
    required this.id,
    required this.professionName,
    required this.phone,
    this.professionId,
  });

  final int id;
  final String professionName;
  final String phone;
  final int? professionId;

  @override
  List<Object?> get props => [id, professionName, phone, professionId];
}
