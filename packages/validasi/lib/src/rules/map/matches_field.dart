import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class MatchesField<T> extends Rule<Map<String, T>> {
  const MatchesField(this.field, this.matchesField,
      {super.message, this.equals});

  final String field;
  final String matchesField;
  final bool Function(T a, T b)? equals;

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value != null) {
      final hasField = value.containsKey(field);
      final hasMatches = value.containsKey(matchesField);

      if (hasField && hasMatches) {
        final fieldValue = value[field];
        final matchesValue = value[matchesField];

        final isEqual = equals?.call(fieldValue as T, matchesValue as T) ??
            fieldValue == matchesValue;

        if (!isEqual) {
          state.addError(ValidationError(
            rule: 'MatchesField',
            message: message ?? 'Field $field must match $matchesField',
          ));
        }
      }
    }
    return value;
  }
}
