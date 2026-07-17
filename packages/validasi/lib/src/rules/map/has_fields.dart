import 'package:validasi/src/rules/map/field_rules.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class HasFields<T> extends Rule<Map<String, T>> {
  const HasFields(this.fields);

  final Map<String, FieldRules<Object?>> fields;

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value == null) return null;

    for (final entry in fields.entries) {
      final before = state.errors.length;
      applyRules(value[entry.key], entry.value.rules, state);
      for (var j = before; j < state.errors.length; j++) {
        state.errors[j].prefix(entry.key);
      }
    }
    return value;
  }

  @override
  Future<Map<String, T>?> applyAsync(
      Map<String, T>? value, ValidationState state) async {
    if (value == null) return null;

    for (final entry in fields.entries) {
      final before = state.errors.length;
      await applyRulesAsync(value[entry.key], entry.value.rules, state);
      for (var j = before; j < state.errors.length; j++) {
        state.errors[j].prefix(entry.key);
      }
    }
    return value;
  }
}
