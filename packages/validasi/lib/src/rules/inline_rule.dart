import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class InlineRule<T> extends Rule<T> {
  const InlineRule(
    this.validator, {
    super.message,
    this.name = 'inline_rule',
  });

  final String name;
  final bool Function(T? value) validator;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'InlineRule',
        parameters: {'name': name},
        runOnNull: runOnNull,
        message: message,
        isDynamic: true,
        dynamicReason: 'Validator callback logic cannot be introspected.',
      );

  @override
  bool get runOnNull => true;

  @override
  T? apply(T? value, ValidationState state) {
    try {
      final result = validator(value);

      if (!result) {
        state.addError(
          ValidationError(
            rule: name,
            message: message ?? 'Validation failed',
          ),
        );
      }
    } catch (e) {
      state.addError(
        ValidationError(
          rule: name,
          message: message ?? e.toString(),
        ),
      );
    }
    return value;
  }
}
