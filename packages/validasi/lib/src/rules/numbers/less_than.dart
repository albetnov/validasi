import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

class LessThan<T extends num> extends Rule<T> {
  const LessThan(this.max, {super.message});

  final T max;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'LessThan',
        parameters: {'max': max},
        runOnNull: runOnNull,
        message: message,
      );

  @override
  void apply(ValidationContext<T> context) {
    if (context.requireValue >= max) {
      context.addError(ValidationError(
        rule: 'lessThan',
        message: message ?? 'value must be less than $max',
      ));
    }
  }
}
