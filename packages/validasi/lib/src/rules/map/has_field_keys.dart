import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class HasFieldKeys<T> extends Rule<Map<String, T>> {
  HasFieldKeys(this.keys);

  final Set<String> keys;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'HasFieldKeys',
        parameters: {
          'keys': keys.toList()..sort(),
        },
        runOnNull: runOnNull,
        message: message,
      );

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value != null) {
      final missingKeys = keys.where((key) => !value.containsKey(key)).toList();

      if (missingKeys.isNotEmpty) {
        state.errors.add(ValidationError(
          rule: 'hasFieldKeys',
          message: 'Missing required fields: ${missingKeys.join(', ')}',
        ));
      }
    }
    return value;
  }
}
