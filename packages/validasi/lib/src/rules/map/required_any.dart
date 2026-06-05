import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class RequiredAny<T> extends Rule<Map<String, T>> {
  const RequiredAny(this.fields, {super.message});

  final List<String> fields;

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value != null) {
      final hasAny = fields.any((field) => value.containsKey(field));

      if (!hasAny) {
        state.addError(ValidationError(
          rule: 'RequiredAny',
          message:
              message ?? 'At least one of ${fields.join(', ')} is required',
        ));
      }
    }
    return value;
  }
}
