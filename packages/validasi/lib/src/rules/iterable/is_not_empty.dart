import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class IsNotEmpty<T> extends Rule<List<T>> {
  const IsNotEmpty({super.message});

  @override
  List<T>? apply(List<T>? value, ValidationState state) {
    if (value != null && value.isEmpty) {
      state.addError(ValidationError(
        rule: 'IsNotEmpty',
        message: message ?? 'List must not be empty',
      ));
    }
    return value;
  }
}
