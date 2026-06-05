import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Contains<T> extends Rule<List<T>> {
  const Contains(this.element, {super.message, this.equals});

  final T element;
  final bool Function(T a, T b)? equals;

  @override
  List<T>? apply(List<T>? value, ValidationState state) {
    if (value != null) {
      final found = value.any(
        (item) => equals?.call(item, element) ?? item == element,
      );
      if (!found) {
        state.addError(ValidationError(
          rule: 'Contains',
          message: message ?? 'List must contain $element',
        ));
      }
    }
    return value;
  }
}
