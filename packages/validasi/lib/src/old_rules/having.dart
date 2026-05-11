import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/rule_metadata.dart';

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
  void apply(ValidationContext<T> context) {
    final value = context.value;

    if (!validValues.contains(value)) {
      context.addError(
        ValidationError(
          rule: 'having',
          message: message ?? 'Value must be one of: ${validValues.join(', ')}',
        ),
      );
    }
  }
}
