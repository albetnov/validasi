import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';

class LessThanEqual<T extends num> extends Rule<T> {
  const LessThanEqual(this.max, {super.message});

  final T max;

  @override
  void apply(ValidationContext<T> context) {
    if (context.requireValue > max) {
      context.addError(ValidationError(
        rule: 'lessThanEqual',
        message: message ?? 'value must be less than or equal to $max',
      ));
    }
  }
}
