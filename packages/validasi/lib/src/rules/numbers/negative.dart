import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Negative<T extends num> extends Rule<T> {
  const Negative({super.message});

  @override
  T? apply(T? value, ValidationState state) {
    if (value != null && value >= 0) {
      state.addError(ValidationError(
        rule: 'negative',
        message: message ?? 'value must be negative',
      ));
    }
    return value;
  }
}
