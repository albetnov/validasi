import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class Finite extends Rule<double> {
  const Finite({super.message});

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'Finite',
        runOnNull: runOnNull,
        message: message,
      );

  @override
  double? apply(double? value, ValidationState state) {
    if (value != null && !value.isFinite) {
      state.addError(ValidationError(
        rule: 'finite',
        message: message ?? 'value must be a finite number',
      ));
    }
    return value;
  }
}
