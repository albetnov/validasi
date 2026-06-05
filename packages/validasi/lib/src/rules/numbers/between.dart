import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Between<T extends num> extends Rule<T> {
  const Between(this.min, this.max, {super.message});

  final T min;
  final T max;

  @override
  T? apply(T? value, ValidationState state) {
    if (value != null && (value < min || value > max)) {
      state.addError(ValidationError(
        rule: 'between',
        message: message ?? 'value must be between $min and $max',
      ));
    }
    return value;
  }
}
