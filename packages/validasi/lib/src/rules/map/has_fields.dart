import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

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
  void apply(ValidationContext<Map<String, T>> context) {
    for (var field in fields.entries) {
      final key = field.key;
      final engine = field.value;

      final value = context.requireValue[key];
      final result = engine.validate(value);

      if (!result.isValid) {
        for (final error in result.errors) {
          context.addError(error.withPrefix(key));
        }
      }
    }
  }
}
