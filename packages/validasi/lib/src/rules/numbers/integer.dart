import 'package:validasi/src/engine/error.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

class Integer extends Rule<int> {
  const Integer({super.message});

  @override
  int? apply(int? value, ValidationState state) {
    if (value != null && !value.isFinite) {
      state.addError(ValidationError(
        rule: 'integer',
        message: message ?? 'value must be a finite integer',
      ));
    }
    return value;
  }
}
