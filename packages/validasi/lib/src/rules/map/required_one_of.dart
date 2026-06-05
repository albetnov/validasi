import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class RequiredOneOf<T> extends Rule<Map<String, T>> {
  const RequiredOneOf(this.fields, {super.message});

  final List<String> fields;

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value != null) {
      final presentCount =
          fields.where((field) => value.containsKey(field)).length;

      if (presentCount != 1) {
        state.addError(ValidationError(
          rule: 'RequiredOneOf',
          message: message ?? 'Exactly one of ${fields.join(', ')} is required',
        ));
      }
    }
    return value;
  }
}
