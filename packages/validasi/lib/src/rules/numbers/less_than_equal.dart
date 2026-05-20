import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class LessThanEqual<T extends num> extends Rule<T> {
  const LessThanEqual(this.max, {super.message});

  final T max;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'LessThanEqual',
        parameters: {'max': max},
        runOnNull: runOnNull,
        message: message,
      );

  @override
  T? apply(T? value, ValidationState state) {
    if (value != null && value > max) {
      state.addError(ValidationError(
        rule: 'lessThanEqual',
        message: message ?? 'value must be less than or equal to $max',
      ));
    }
    return value;
  }
}
