import 'package:validasi/src/rule.dart';

class Nullable<T> extends Rule<T> {
  const Nullable() : super('nullable');

  @override
  ValidateResult validate(T? value) {
    if (value == null) {
      return ValidateResult.stop();
    }

    return ValidateResult.success();
  }
}
