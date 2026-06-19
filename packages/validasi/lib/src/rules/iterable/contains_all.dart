import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

/// Validates that a list contains all required elements.
///
/// Uses one of two strategies depending on the parameters provided:
///   - **Native (O(N+M))**: Converts value to a `Set` for O(1) lookups.
///   - **Key (O(N+M))**: Custom `keySelector` extracts a key per element.
class ContainsAll<T> extends Rule<List<T>> {
  const ContainsAll(this.elements, {super.message, this.keySelector});

  final List<T> elements;
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
    final set = value.toSet();
    for (final required in elements) {
      if (!set.contains(required)) {
        state.addError(_error());
        return value;
      }
    }
    return value;
  }

  List<T>? _validateByKey(List<T> value, ValidationState state) {
    final keys = value.map(keySelector!).toSet();
    for (final required in elements) {
      if (!keys.contains(keySelector!(required))) {
        state.addError(_error());
        return value;
      }
    }
    return value;
  }

  ValidationError _error() => ValidationError(
        rule: 'ContainsAll',
        message: message ?? 'List must contain all required elements',
      );
}
