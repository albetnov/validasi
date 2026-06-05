import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class MinKeys<T> extends Rule<Map<String, T>> {
  const MinKeys(this.min, {super.message});

  final int min;

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value != null && value.length < min) {
      state.addError(ValidationError(
        rule: 'MinKeys',
        message: message ?? 'Map must have at least $min keys',
      ));
    }
    return value;
  }
}
