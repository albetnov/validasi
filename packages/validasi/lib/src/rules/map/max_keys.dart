import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class MaxKeys<T> extends Rule<Map<String, T>> {
  const MaxKeys(this.max, {super.message});

  final int max;

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value != null && value.length > max) {
      state.addError(ValidationError(
        rule: 'MaxKeys',
        message: message ?? 'Map must have at most $max keys',
      ));
    }
    return value;
  }
}
