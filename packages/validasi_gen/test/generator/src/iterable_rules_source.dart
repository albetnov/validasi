import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class IterableRulesModel {
  @Validate<List<String>>([ExactLength(3)])
  final List<String> exactLength;

  @Validate<List<String>>([IsEmpty()])
  final List<String> isEmpty;

  @Validate<List<String>>([IsNotEmpty()])
  final List<String> isNotEmpty;

  @Validate<List<String>>([Unique()])
  final List<String> unique;

  @Validate<List<String>>([
    ContainsAll(['a', 'b'])
  ])
  final List<String> containsAll;

  @Validate<List<String>>([NotContains('x')])
  final List<String> notContains;

  @Validate<List<String>>([Contains('needle')])
  final List<String> contains;

  const IterableRulesModel({
    required this.exactLength,
    required this.isEmpty,
    required this.isNotEmpty,
    required this.unique,
    required this.containsAll,
    required this.notContains,
    required this.contains,
  });
}
