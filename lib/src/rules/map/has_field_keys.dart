import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

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
  void apply(ValidationContext<Map<String, T>> context) {
    final missingKeys =
        keys.where((key) => !context.requireValue.containsKey(key)).toList();

    if (missingKeys.isNotEmpty) {
      context.addError(ValidationError(
        rule: 'hasFieldKeys',
        message: 'Missing required fields: ${missingKeys.join(', ')}',
      ));
    }
  }
}
