import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

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
  T? apply(T? value, ValidationState state) {
    if (value == null) {
      state.errors.add(ValidationError(
        rule: 'Required',
        message: message ?? 'Field is required',
      ));
    }
    return value;
  }
}
