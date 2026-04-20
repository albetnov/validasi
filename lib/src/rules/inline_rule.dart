import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

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
  void apply(ValidationContext<T> context) {
    try {
      final result = validator(context.value);

      if (!result) {
        context.addError(
          ValidationError(
            rule: name,
            message: message ?? 'Validation failed',
          ),
        );
      }
    } catch (e) {
      context.addError(
        ValidationError(
          rule: name,
          message: message ?? e.toString(),
        ),
      );
    }
  }
}
