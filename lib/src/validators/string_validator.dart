import 'package:validasi/src/validators/validator.dart';

/// Responsible for validating [String] also support [toString] conversion.
class StringValidator extends Validator<String> {
  StringValidator({super.transformer});

  /// [required] indicate that the value should not be `null` and is
  /// not empty and blank.
  StringValidator required({String? message}) {
    addRule(
      name: 'required',
      test: (text) => text != null && text.trim() != '' && text.isNotEmpty,
      message: message ?? ":name is required",
    );

    return this;
  }

  /// [minLength] check if the value satisfy the minimum length based on
  /// [length].
  StringValidator minLength(int length, {String? message}) {
    addRule(
      name: 'minLength',
      test: (text) {
        if (text == null) return false;

        return text.length >= length;
      },
      message: message ?? ":name must be at least contains $length characters",
    );

    return this;
  }

  /// [maxLength] check if the value is under or equal to maximum [length].
  StringValidator maxLength(int length, {String? message}) {
    addRule(
      name: 'maxLength',
      test: (text) {
        if (text == null) return false;

        return text.length <= length;
      },
      message: message ?? ":name must not be longer than $length characters",
    );

    return this;
  }

  @override
  StringValidator custom(callback) => super.custom(callback);

  @override
  StringValidator customFor(customRule) => super.customFor(customRule);
}
