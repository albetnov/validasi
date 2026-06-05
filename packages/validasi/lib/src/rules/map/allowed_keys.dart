import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class AllowedKeys<T> extends Rule<Map<String, T>> {
  const AllowedKeys(this.keys, {super.message});

  final Set<String> keys;

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value != null) {
      final extraKeys = value.keys.where((key) => !keys.contains(key)).toList();

      if (extraKeys.isNotEmpty) {
        state.addError(ValidationError(
          rule: 'AllowedKeys',
          message: message ?? 'Unknown fields: ${extraKeys.join(', ')}',
        ));
      }
    }
    return value;
  }
}
