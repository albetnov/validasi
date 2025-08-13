import 'package:validasi/src/rule.dart';

class MaxLength extends Rule<String> {
  const MaxLength({
    required this.length,
  }) : super('maxLength');

  final int length;

  @override
  ValidateResult validate(String? value) {
    if (value != null && value.length <= length) {
      return ValidateResult.success();
    }

    return ValidateResult.failure(
      'Maximum length is $length characters',
      details: {
        'length': length.toString(),
      },
    );
  }
}
