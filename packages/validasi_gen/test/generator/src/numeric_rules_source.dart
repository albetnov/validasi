import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class NumericRulesModel {
  @Validate<int>([Between(1, 10)])
  final int between;

  @Validate<int>([LessThan(10)])
  final int lessThan;

  @Validate<int>([LessThanEqual(10)])
  final int lessThanEqual;

  @Validate<int>([MoreThan(1)])
  final int moreThan;

  @Validate<int>([MoreThanEqual(1)])
  final int moreThanEqual;

  @Validate<int>([Negative()])
  final int negative;

  @Validate<int>([NonNegative()])
  final int nonNegative;

  @Validate<int>([NonPositive()])
  final int nonPositive;

  @Validate<int>([Positive()])
  final int positive;

  @Validate<double>([Finite()])
  final double finite;

  const NumericRulesModel({
    required this.between,
    required this.lessThan,
    required this.lessThanEqual,
    required this.moreThan,
    required this.moreThanEqual,
    required this.negative,
    required this.nonNegative,
    required this.nonPositive,
    required this.positive,
    required this.finite,
  });
}
