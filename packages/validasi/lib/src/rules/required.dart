import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

class Required<T> extends Rule<T> {
  const Required({super.message});

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'Required',
        runOnNull: runOnNull,
        message: message,
      );

  @override
  bool get runOnNull => true;

  @override
  void apply(ValidationContext context) {
    if (context.value == null) {
      context.addError(ValidationError(
        rule: 'Required',
        message: message ?? 'Field is required',
      ));
    }
  }
}
