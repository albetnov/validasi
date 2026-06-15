import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

/// Validates that a list contains a specific element.
///
/// Uses one of two strategies depending on the parameters provided:
///   - **Native (O(k))**: Short-circuits on match via `value.any()`.
///   - **Key (O(k))**: Custom `keySelector` with short-circuit iteration.
class Contains<T> extends Rule<List<T>> {
  const Contains(this.element, {super.message, this.keySelector});

  final T element;
  final Object? Function(T)? keySelector;

  @override
  List<T>? apply(List<T>? value, ValidationState state) {
    if (value != null) {
      if (keySelector != null) {
        return _validateByKey(value, state);
      }
      return _validateNative(value, state);
    }
    return value;
  }

  List<T>? _validateNative(List<T> value, ValidationState state) {
    final found = value.any((item) => item == element);
    if (!found) state.addError(_error());
    return value;
  }

  List<T>? _validateByKey(List<T> value, ValidationState state) {
    final targetKey = keySelector!(element);
    final found = value.any((item) => keySelector!(item) == targetKey);
    if (!found) state.addError(_error());
    return value;
  }

  ValidationError _error() => ValidationError(
        rule: 'Contains',
        message: message ?? 'List must contain $element',
      );
}
