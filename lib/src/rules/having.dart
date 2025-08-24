import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';

class Having<T> extends Rule<T> {
  const Having(this.validValues, {super.message});

  final List<T> validValues;

  @override
  void apply(ValidationContext context) {
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
