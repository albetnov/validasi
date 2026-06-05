import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Positive<T extends num> extends Rule<T> {
  const Positive({super.message});

  @override
  T? apply(T? value, ValidationState state) {
    if (value != null && value <= 0) {
      state.addError(ValidationError(
        rule: 'positive',
        message: message ?? 'value must be positive',
      ));
    }
    return value;
  }
}
