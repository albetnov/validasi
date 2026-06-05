import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class NotEquals<T> extends Rule<T> {
  const NotEquals(this.unexpected, {super.message, this.equals});

  final T unexpected;
  final bool Function(T a, T b)? equals;

  @override
  T? apply(T? value, ValidationState state) {
    if (value != null) {
      final isEqual = equals?.call(value, unexpected) ?? value == unexpected;

      if (isEqual) {
        state.addError(ValidationError(
          rule: 'NotEquals',
          message: message ?? 'Value must not equal $unexpected',
        ));
      }
    }
    return value;
  }
}
