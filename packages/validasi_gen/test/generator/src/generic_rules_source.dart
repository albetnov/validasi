import 'package:validasi_annotation/validasi_annotation.dart';

enum Status { active, inactive }

@ValidateClass()
class GenericRulesModel {
  @Validate<String>([Equals('exact')])
  final String equals;

  @Validate<String>([NotEquals('forbidden')])
  final String notEquals;

  @Validate<Status>([Having([Status.active, Status.inactive])])
  final Status status;

  const GenericRulesModel({
    required this.equals,
    required this.notEquals,
    required this.status,
  });
}
