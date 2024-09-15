import 'package:validasi/src/validators/validator.dart';

/// Responsible for validating [num] for both [double] and [int] also
/// support type conversion from [String] based on [num.tryParse].
class NumberValidator extends Validator<num> {
  NumberValidator({super.transformer});

  /// [required] indicate that the [value] cannot be `null`
  NumberValidator required({String? message}) {
    addRule(
      name: 'required',
      test: (value) => value != null,
      message: message ?? ':name is required',
    );

    return this;
  }

  @override
  NumberValidator custom(callback) => super.custom(callback);

  @override
  NumberValidator customFor(customRule) => super.customFor(customRule);
}
