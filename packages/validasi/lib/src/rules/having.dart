import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';
import 'package:validasi/src/engine/state.dart';

class Having<T> extends Rule<T> {
  const Having(this.validValues, {super.message});

  final List<T> validValues;

  @override
  RuleMetadata get metadata => RuleMetadata(
        name: 'Having',
        parameters: {
          'validValues': validValues.map((value) => '$value').toList(),
        },
        runOnNull: runOnNull,
        message: message,
      );

  @override
  bool get runOnNull => true;

  @override
  T? apply(T? value, ValidationState state) {
    if (!validValues.contains(value)) {
      state.errors.add(
        ValidationError(
          rule: 'having',
          message: message ?? 'Value must be one of: ${validValues.join(', ')}',
        ),
      );
    }
    return value;
  }
}
