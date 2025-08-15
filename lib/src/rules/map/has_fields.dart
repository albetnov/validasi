import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/rule.dart';

class HasFields extends Rule<Map<String, dynamic>> {
  const HasFields(this.fields);

  final Map<String, ValidasiEngine<dynamic>> fields;

  @override
  void apply(ValidationContext context) {
    for (var field in fields.entries) {
      final key = field.key;
      final engine = field.value;

      final value = context.value[key];
      final result = engine.validate(value);

      if (!result.isValid) {
        for (final error in result.errors) {
          context.errors.add(error.withPrefix(key));
        }
      }
    }
  }
}
