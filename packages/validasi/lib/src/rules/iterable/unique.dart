import 'dart:collection';

import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

/// Validates that all elements in a list are unique.
///
/// Uses one of three strategies depending on the parameters provided:
///   - **Native (O(N))**: No custom params. Uses `toSet()` + `Set` iteration.
///   - **LinkedHashSet (O(N))**: Custom `equals` + `hasher`. Provide both for
///     optimal performance.
///   - **Fallback (O(N²))**: Custom `equals` without `hasher`. Avoid this —
///     always provide `hasher` when using custom equality.
///   - **Key (O(N))**: Custom `keySelector`. Extracts a key per element and
///     tracks them in a `Set`.
class Unique<T> extends Rule<List<T>> {
  const Unique({
    super.message,
    this.equals,
    this.hasher,
    this.keySelector,
  });

  final bool Function(T a, T b)? equals;
  final int Function(T)? hasher;
  final Object? Function(T)? keySelector;

  @override
  List<T>? apply(List<T>? value, ValidationState state) {
    if (value == null || value.length < 2) return value;

    if (keySelector != null) {
      return _validateByKey(value, state);
    }

    if (equals != null) {
      return _validateByEquality(value, state);
    }

    return _validateNative(value, state);
  }

  List<T>? _validateNative(List<T> value, ValidationState state) {
    final seen = <T>{};
    for (final item in value) {
      if (!seen.add(item)) {
        state.addError(_error());
        return value;
      }
    }
    return value;
  }

  List<T>? _validateByEquality(List<T> value, ValidationState state) {
    if (hasher != null) {
      final seen = LinkedHashSet<T>(
        equals: equals,
        hashCode: hasher,
      );
      for (final item in value) {
        if (!seen.add(item)) {
          state.addError(_error());
          return value;
        }
      }
      return value;
    }

    // Fallback O(N²) path when equals is provided without hasher.
    // This is slow for large lists — always provide hasher for O(N).
    assert(() {
      // ignore: avoid_print
      print(
        'Warning: Unique with custom equals without hasher uses O(N²) '
        'fallback. Provide hasher for O(N) LinkedHashSet performance.',
      );
      return true;
    }());

    final seen = <T>[];
    for (final item in value) {
      final isDuplicate = seen.any((s) => equals!(s, item));
      if (isDuplicate) {
        state.addError(_error());
        return value;
      }
      seen.add(item);
    }
    return value;
  }

  List<T>? _validateByKey(List<T> value, ValidationState state) {
    final seen = <Object?>{};
    for (final item in value) {
      if (!seen.add(keySelector!(item))) {
        state.addError(_error());
        return value;
      }
    }
    return value;
  }

  ValidationError _error() => ValidationError(
        rule: 'Unique',
        message: message ?? 'List must contain only unique items',
      );
}
