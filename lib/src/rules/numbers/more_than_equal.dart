import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';

class MoreThanEqual<T extends num> extends Rule<T> {
  const MoreThanEqual(this.min, {super.message});

  final T min;

  @override
  void apply(ValidationContext context) {
    if (context.value < min) {
      context.addError(ValidationError(
        rule: 'moreThanEqual',
        message: message ?? 'value must be more than or equal to $min',
      ));
    }
  }
}
