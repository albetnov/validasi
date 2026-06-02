import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class MinLength<T> extends Rule<List<T>> {
  const MinLength(this.length, {super.message});

  final int length;

  @override
  List<T>? apply(List<T>? value, ValidationState state) {
    if (value != null && value.length < length) {
      state.addError(ValidationError(
        rule: 'MinLength',
        message: message ?? 'List must have at least $length items',
      ));
    }
    return value;
  }
}
