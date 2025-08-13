import 'package:validasi/src/rule.dart';

class MinLength extends Rule<String> {
  const MinLength({
    required this.length,
  }) : super('minLength');

  final int length;

  @override
  ValidateResult validate(String? value) {
    if (value != null && value.length >= length) {
      return ValidateResult.success();
    }

    return ValidateResult.failure(
      'Minimum length is $length characters',
      details: {
        'length': length.toString(),
      },
    );
  }
}
