import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class MaxLength extends Rule<String> {
  const MaxLength(
    this.length, {
    super.message,
  });

  final int length;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'MaxLength',
        parameters: {'length': length},
        runOnNull: runOnNull,
        message: message,
      );

  @override
  String? apply(String? value, ValidationState state) {
    if (value != null && value.length > length) {
      state.errors.add(
        ValidationError(
          rule: 'MaxLength',
          message: message ?? 'Maximum length is $length characters',
          details: {'length': length.toString()},
        ),
      );
    }
    return value;
  }
}
