import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class RequiredAll<T> extends Rule<Map<String, T>> {
  const RequiredAll(this.fields, {super.message});

  final List<String> fields;

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value != null) {
      final hasAny = fields.any((field) => value.containsKey(field));

      if (hasAny) {
        final missing =
            fields.where((field) => !value.containsKey(field)).toList();

        if (missing.isNotEmpty) {
          state.addError(ValidationError(
            rule: 'RequiredAll',
            message:
                message ?? 'All fields must be present: ${fields.join(', ')}',
          ));
        }
      }
    }
    return value;
  }
}
