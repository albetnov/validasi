import 'package:email_validator/email_validator.dart';
import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/validators/validator.dart';

enum UrlChecks {
  scheme,
  host,
  httpsOnly,
}

const List<UrlChecks> defaultUrlChecks = [UrlChecks.scheme, UrlChecks.host];

/// Responsible for validating [String] also support [toString] conversion.
class StringValidator extends Validator<String> {
  StringValidator({super.transformer});

  @override
  StringValidator nullable() => super.nullable();

  @override
  StringValidator custom(CustomCallback<String> callback) =>
      super.custom(callback);

  @override
  StringValidator customFor(CustomRule<String> customRule) =>
      super.customFor(customRule);

  /// [minLength] check if the value satisfy the minimum length based on
  /// [length].
  StringValidator minLength(int length, {String? message}) {
    addRule(
      name: 'minLength',
      test: (text) => text.length >= length,
      message: message ?? ":name must contains at least $length characters",
    );

    return this;
  }

  /// [maxLength] check if the value is under or equal to maximum [length].
  StringValidator maxLength(int length, {String? message}) {
    addRule(
      name: 'maxLength',
      test: (text) => text.length <= length,
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
        test: (text) => EmailValidator.validate(
            text, allowTopLevelDomain, allowInternational),
        message: message ?? ':name must be a valid email');

    return this;
  }

  /// Check if the value starts with the given [text].
  StringValidator startsWith(String text, {String? message}) {
    addRule(
        name: 'startsWith',
        test: (value) => value.startsWith(text),
        message: message ?? ':name must start with "$text"');

    return this;
  }

  /// Check if the value ends with the given [text].
  StringValidator endsWith(String text, {String? message}) {
    addRule(
        name: 'endsWith',
        test: (value) => value.endsWith(text),
        message: message ?? ':name must end with "$text"');

    return this;
  }

  /// Check if the value contains the given [text].
  StringValidator contains(String text, {String? message}) {
    addRule(
        name: 'contains',
        test: (value) => value.contains(text),
        message: message ?? ':name must contain "$text"');

    return this;
  }

  /// Check if the value is a valid url using [Uri.tryParse].
  /// [checks] contains the list of check to be performed on the url.
  /// [UrlChecks.scheme] check if the url has a scheme.
  /// [UrlChecks.host] check if the url has a host.
  /// [UrlChecks.httpsOnly] check if the url is https only.
  ///
  /// By default, [checks] contains [UrlChecks.scheme] and [UrlChecks.host] under [defaultUrlChecks].
  /// So only url like `https://example.com` or `http://example.com` will pass.
  StringValidator url({
    String? message,
    List<UrlChecks> checks = defaultUrlChecks,
  }) {
    addRule(
        name: 'url',
        test: (value) {
          final uri = Uri.tryParse(value);

          if (uri == null) {
            return false;
          }

          if (checks.contains(UrlChecks.scheme) ||
              checks.contains(UrlChecks.httpsOnly)) {
            if (uri.scheme.isEmpty) return false;

            if (checks.contains(UrlChecks.httpsOnly) && uri.scheme != 'https') {
              return false;
            }
          }

          if (checks.contains(UrlChecks.host) && uri.host.isEmpty) {
            return false;
          }

          return true;
        },
        message: message ?? ':name must be a valid url');

    return this;
  }

  /// Check if the value match given [pattern] using [RegExp].
  StringValidator regex(String pattern, {String? message}) {
    addRule(
        name: 'regex',
        test: (value) => RegExp(pattern).hasMatch(value),
        message: message ?? ':name must match the pattern');

    return this;
  }
}
