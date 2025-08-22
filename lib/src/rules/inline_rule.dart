import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';

class InlineRule<T> extends Rule<T> {
  const InlineRule(
    this.validator, {
    super.message,
    this.name = 'inline_rule',
  });

  final String name;
  final bool Function(T) validator;

  @override
  void apply(ValidationContext context) {
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
