import 'package:validasi/src/rules/map/field_rules.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class HasFields extends Rule<Map<String, dynamic>> {
  const HasFields(this.fields);

  final Map<String, FieldRules<Object?>> fields;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'HasFields',
        parameters: {
          'fields': fields.keys.toList()..sort(),
        },
        runOnNull: runOnNull,
        message: message,
      );

  @override
  Map<String, Object?> get metadataChildren {
    final keys = fields.keys.toList()..sort();

    return <String, Object?>{
      for (final key in keys) key: fields[key]!,
    };
  }

  @override
  Map<String, dynamic>? apply(
      Map<String, dynamic>? value, ValidationState state) {
    if (value == null) return null;

    for (final entry in fields.entries) {
      final before = state.errors.length;
      applyRules(value[entry.key], entry.value.rules, state);
      for (var j = before; j < state.errors.length; j++) {
        state.errors[j] = state.errors[j].withPrefix(entry.key);
      }
    }
    return value;
  }
}
