import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

class MinLength extends Rule<String> {
  const MinLength(this.length, {super.message});

  final int length;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'MinLength',
        parameters: {'length': length},
        runOnNull: runOnNull,
        message: message,
      );

  @override
  void apply(ValidationContext<String> context) {
    if (context.requireValue.length >= length) {
      return;
    }

    context.addError(
      ValidationError(
        rule: 'MinLength',
        message: message ?? 'Minimum length is $length characters',
        details: {'length': length.toString()},
      ),
    );
  }
}
