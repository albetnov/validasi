import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class NonPositive<T extends num> extends Rule<T> {
  const NonPositive({super.message});

  @override
  T? apply(T? value, ValidationState state) {
    if (value != null && value > 0) {
      state.addError(ValidationError(
        rule: 'nonPositive',
        message: message ?? 'value must be non-positive',
      ));
    }
    return value;
  }
}
