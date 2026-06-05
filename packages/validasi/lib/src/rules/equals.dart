import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Equals<T> extends Rule<T> {
  const Equals(this.expected, {super.message, this.equals});

  final T expected;
  final bool Function(T a, T b)? equals;

  @override
  T? apply(T? value, ValidationState state) {
    if (value != null) {
      final isEqual = equals?.call(value, expected) ?? value == expected;

      if (!isEqual) {
        state.addError(ValidationError(
          rule: 'Equals',
          message: message ?? 'Value must equal $expected',
        ));
      }
    }
    return value;
  }
}
