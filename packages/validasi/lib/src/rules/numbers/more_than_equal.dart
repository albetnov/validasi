import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

class MoreThanEqual<T extends num> extends Rule<T> {
  const MoreThanEqual(this.min, {super.message});

  final T min;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'MoreThanEqual',
        parameters: {'min': min},
        runOnNull: runOnNull,
        message: message,
      );

  @override
  void apply(ValidationContext<T> context) {
    if (context.requireValue < min) {
      context.addError(ValidationError(
        rule: 'moreThanEqual',
        message: message ?? 'value must be more than or equal to $min',
      ));
    }
  }
}
