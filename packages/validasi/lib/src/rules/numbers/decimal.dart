import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Decimal extends Rule<double> {
  const Decimal({super.message});

  @override
  double? apply(double? value, ValidationState state) {
    if (value != null && !value.isFinite) {
      state.addError(ValidationError(
        rule: 'decimal',
        message: message ?? 'value must be a finite decimal',
      ));
    }
    return value;
  }
}
