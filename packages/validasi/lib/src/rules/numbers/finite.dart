import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

class Finite extends Rule<double> {
  const Finite({super.message});

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'Finite',
        runOnNull: runOnNull,
        message: message,
      );

  @override
  void apply(ValidationContext<double> context) {
    if (context.requireValue.isFinite == false) {
      context.addError(ValidationError(
        rule: 'finite',
        message: message ?? 'value must be a finite number',
      ));
    }
  }
}
