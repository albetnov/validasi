import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';

class Finite extends Rule<double> {
  const Finite({super.message});

  @override
  void apply(ValidationContext<double> context) {
    if (context.requireValue.isInfinite == false) {
      context.addError(ValidationError(
        rule: 'finite',
        message: message ?? 'value must be a finite number',
      ));
    }
  }
}
