import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class MoreThan<T extends num> extends Rule<T> {
  const MoreThan(this.min, {super.message});

  final T min;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'MoreThan',
        parameters: {'min': min},
        runOnNull: runOnNull,
        message: message,
      );

  @override
  T? apply(T? value, ValidationState state) {
    if (value != null && value <= min) {
      state.addError(ValidationError(
        rule: 'moreThan',
        message: message ?? 'value must be more than $min',
      ));
    }
    return value;
  }
}
