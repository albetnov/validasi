import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class IsEmpty<T> extends Rule<List<T>> {
  const IsEmpty({super.message});

  @override
  List<T>? apply(List<T>? value, ValidationState state) {
    if (value != null && value.isNotEmpty) {
      state.addError(ValidationError(
        rule: 'IsEmpty',
        message: message ?? 'List must be empty',
      ));
    }
    return value;
  }
}
