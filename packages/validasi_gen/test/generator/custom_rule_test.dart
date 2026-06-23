import 'basic_test.dart' show generateForSource;
import 'package:test/test.dart';

Future<void> main() async {
  group('CustomRule generation', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'custom_rule_source.dart',
      );
    });

    test('generates IsEmail check with config param', () {
      expect(
        output,
        contains(
          "email != null && !IsEmail.check(email, domain: 'example.com')",
        ),
      );
    });

    test('generates NonEmpty check without config params', () {
      expect(
        output,
        contains('email != null && !NonEmpty.check(email)'),
      );
    });

    test('uses custom rule name in error rule field', () {
      expect(output, contains("rule: 'isEmail'"));
      expect(output, contains("rule: 'nonEmpty'"));
    });

    test('uses default message format for custom rules', () {
      expect(output, contains("'isEmail: validation failed.'"));
      expect(output, contains("'nonEmpty: validation failed.'"));
    });

    test('preserves built-in rule behaviour alongside custom rules', () {
      expect(output, contains('if (value != null && value.length < 2)'));
      expect(output, contains("rule: 'MinLength'"));
    });

    test('generates sealed fields class for CustomRuleModel', () {
      expect(
        output,
        contains(
          'sealed class CustomRuleModelFields<V> extends ValidasiKey<CustomRuleModel>',
        ),
      );
    });

    test('generates validate extension for CustomRuleModel', () {
      expect(
        output,
        contains('extension \$CustomRuleModelValidasi on CustomRuleModel'),
      );
    });
  });

  group('Inline generation', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'custom_rule_source.dart',
      );
    });

    test('generates Inline function call with runOnNull false', () {
      expect(
        output,
        contains('label != null && !_isEmail(label)'),
      );
    });

    test('generates error rule name from Inline name param', () {
      expect(output, contains("rule: 'positive'"));
    });

    test('generates default message for Inline', () {
      expect(output, contains("'positive: validation failed.'"));
    });

    test('skips non-annotated field in validate', () {
      expect(output, contains('sealed class InlineModelFields'));
      expect(output, isNot(contains('InlineNoteField')));
    });
  });

  group('AsyncCustomRule generation', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'custom_rule_source.dart',
      );
    });

    test('emits await call with config param', () {
      expect(output, contains('try {'));
      expect(
        output,
        contains('!await ValidatePassword.check(password, minLength: 8)'),
      );
      expect(output, contains('} catch (e) {'));
    });

    test('uses rule name in error rule field', () {
      expect(output, contains("rule: 'validatePassword'"));
    });

    test('uses default message format for async custom rules', () {
      expect(output, contains("'validatePassword: validation failed.'"));
    });

    test('emits error on catch', () {
      expect(output, contains("rule: 'validatePassword'"));
      expect(output, contains('message: e.toString()'));
    });

    test('throws on sync validate when async custom rules exist', () {
      expect(
        output,
        contains(
          "throw StateError('Async rules cannot be used with validate(). Use validateAsync() instead.');",
        ),
      );
    });
  });
}
