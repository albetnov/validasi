import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class AsyncInlineRule<T> extends AsyncRule<T> {
  const AsyncInlineRule(
    this.validator, {
    super.message,
    this.name = 'async_inline_rule',
  });

  final String name;
  final Future<bool> Function(T? value) validator;

  @override
  bool get runOnNull => true;

  @override
  Future<T?> applyAsync(T? value, ValidationState state) async {
    try {
      final result = await validator(value);

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
