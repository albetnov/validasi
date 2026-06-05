import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class DependsOn<T> extends Rule<Map<String, T>> {
  const DependsOn(this.field, this.dependsOn, {super.message});

  final String field;
  final String dependsOn;

  @override
  Map<String, T>? apply(Map<String, T>? value, ValidationState state) {
    if (value != null) {
      final hasField = value.containsKey(field);
      final hasDependency = value.containsKey(dependsOn);

      if (hasField && !hasDependency) {
        state.addError(ValidationError(
          rule: 'DependsOn',
          message: message ?? 'Field $field requires $dependsOn',
        ));
      }
    }
    return value;
  }
}
