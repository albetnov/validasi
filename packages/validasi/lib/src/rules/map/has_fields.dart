import 'package:validasi/src/rules/map/field_rules.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class HasFields extends Rule<Map<String, dynamic>> {
  const HasFields(this.fields);

  final Map<String, FieldRules<Object?>> fields;

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

  @override
  Future<Map<String, dynamic>?> applyAsync(
      Map<String, dynamic>? value, ValidationState state) async {
    if (value == null) return null;

    for (final entry in fields.entries) {
      final before = state.errors.length;
      await applyRulesAsync(value[entry.key], entry.value.rules, state);
      for (var j = before; j < state.errors.length; j++) {
        state.errors[j] = state.errors[j].withPrefix(entry.key);
      }
    }
    return value;
  }
}
