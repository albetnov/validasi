import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class ForbiddenKeys<T> extends Rule<Map<String, T>> {
  const ForbiddenKeys(this.keys, {super.message});

  final Set<String> keys;

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value != null) {
      final forbidden = value.keys.where((key) => keys.contains(key)).toList();

      if (forbidden.isNotEmpty) {
        state.addError(ValidationError(
          rule: 'ForbiddenKeys',
          message: message ?? 'Forbidden fields: ${forbidden.join(', ')}',
        ));
      }
    }
    return value;
  }
}
