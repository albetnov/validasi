import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class HasFields<T> extends Rule<Map<String, T>> {
  const HasFields(this.fields);

  final Map<String, ValidasiEngine<T, dynamic>> fields;

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
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value == null) return null;

    for (var field in fields.entries) {
      final key = field.key;
      final engine = field.value;
      final before = state.errors.length;
      engine.execute(value[key], state);
      for (var j = before; j < state.errors.length; j++) {
        state.errors[j] = state.errors[j].withPrefix(key);
      }
    }
    return value;
  }
}
