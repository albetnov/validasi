import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class NonNegative<T extends num> extends Rule<T> {
  const NonNegative({super.message});

  @override
  T? apply(T? value, ValidationState state) {
    if (value != null && value < 0) {
      state.addError(ValidationError(
        rule: 'nonNegative',
        message: message ?? 'value must be non-negative',
      ));
    }
    return value;
  }
}
