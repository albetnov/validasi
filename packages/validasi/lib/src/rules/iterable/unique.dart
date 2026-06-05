import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Unique<T> extends Rule<List<T>> {
  const Unique({super.message, this.equals});

  final bool Function(T a, T b)? equals;

  @override
  List<T>? apply(List<T>? value, ValidationState state) {
    if (value != null) {
      final seen = <T>[];
      for (final item in value) {
        final isDuplicate = seen.any(
          (s) => equals?.call(s, item) ?? s == item,
        );
        if (isDuplicate) {
          state.addError(ValidationError(
            rule: 'Unique',
            message: message ?? 'List must contain only unique items',
          ));
          return value;
        }
        seen.add(item);
      }
    }
    return value;
  }
}
