import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class ContainsAll<T> extends Rule<List<T>> {
  const ContainsAll(this.elements, {super.message, this.equals});

  final List<T> elements;
  final bool Function(T a, T b)? equals;

  @override
  List<T>? apply(List<T>? value, ValidationState state) {
    if (value != null) {
      for (final required in elements) {
        final found = value.any(
          (item) => equals?.call(item, required) ?? item == required,
        );
        if (!found) {
          state.addError(ValidationError(
            rule: 'ContainsAll',
            message: message ?? 'List must contain all required elements',
          ));
          return value;
        }
      }
    }
    return value;
  }
}
