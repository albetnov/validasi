import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class ExactLength<T> extends Rule<List<T>> {
  const ExactLength(this.length, {super.message});

  final int length;

  @override
  List<T>? apply(List<T>? value, ValidationState state) {
    if (value != null && value.length != length) {
      state.addError(ValidationError(
        rule: 'ExactLength',
        message: message ?? 'List must have exactly $length items',
      ));
    }
    return value;
  }
}
