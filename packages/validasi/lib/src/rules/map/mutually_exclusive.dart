import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class MutuallyExclusive<T> extends Rule<Map<String, T>> {
  const MutuallyExclusive(this.fieldA, this.fieldB, {super.message});

  final String fieldA;
  final String fieldB;

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value != null) {
      final hasA = value.containsKey(fieldA);
      final hasB = value.containsKey(fieldB);

      if (hasA && hasB) {
        state.addError(ValidationError(
          rule: 'MutuallyExclusive',
          message:
              message ?? 'Fields $fieldA and $fieldB cannot both be present',
        ));
      }
    }
    return value;
  }
}
