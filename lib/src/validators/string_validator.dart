import 'package:email_validator/email_validator.dart';
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

  /// Check if the value is a valid email address.
  ///
  /// [allowTopLevelDomain] allow top level domain in the email address.
  /// [allowInternational] allow international domain in the email address.
  StringValidator email(
      {bool allowTopLevelDomain = false,
      bool allowInternational = false,
      String? message}) {
    addRule(
        name: 'email',
        test: (text) {
          if (text == null) return false;

          return EmailValidator.validate(
              text, allowTopLevelDomain, allowInternational);
        },
        message: message ?? ':name must be a valid email');

    return this;
  }

  /// Check if the value starts with the given [text].
  StringValidator startsWith(String text, {String? message}) {
    addRule(
        name: 'startsWith',
        test: (value) {
          if (value == null) return false;

          return value.startsWith(text);
        },
        message: message ?? ':name must start with "$text"');

    return this;
  }

  /// Check if the value ends with the given [text].
  StringValidator endsWith(String text, {String? message}) {
    addRule(
        name: 'endsWith',
        test: (value) {
          if (value == null) return false;

          return value.endsWith(text);
        },
        message: message ?? ':name must end with "$text"');

    return this;
  }

  /// Check if the value contains the given [text].
  StringValidator contains(String text, {String? message}) {
    addRule(
        name: 'contains',
        test: (value) {
          if (value == null) return false;

          return value.contains(text);
        },
        message: message ?? ':name must contain "$text"');

    return this;
  }

  /// Check if the value is a valid url.
  StringValidator url({String? message}) {
    addRule(
        name: 'url',
        test: (value) {
          if (value == null) return false;

          return Uri.tryParse(value) != null;
        },
        message: message ?? ':name must be a valid url');

    return this;
  }

  /// Check if the value match given [pattern].
  StringValidator regex(String pattern, {String? message}) {
    addRule(
        name: 'regex',
        test: (value) {
          if (value == null) return false;

          return RegExp(pattern).hasMatch(value);
        },
        message: message ?? ':name must match the pattern');

    return this;
  }

  @override
  StringValidator custom(callback) => super.custom(callback);

  @override
  StringValidator customFor(customRule) => super.customFor(customRule);
}
