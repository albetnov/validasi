import 'basic_test.dart' show generateForSource;
import 'package:test/test.dart';

Future<void> main() async {
  group('Validate.any with Inline on enum', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'any_validation_source.dart',
      );
    });

    test('generates Inline function call for enum field', () {
      expect(output, contains('!_isValidStatus(status)'));
    });

    test('uses custom name from Inline in error rule', () {
      expect(output, contains("'validStatus'"));
    });
  });

  group('Validate.any with OneOf on enum', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'any_validation_source.dart',
      );
    });

    test('generates OneOf check with enum literals', () {
      expect(
        output,
        contains('![Status.pending, Status.active].contains(role)'),
      );
    });
  });

  group('Validate.any with OneOf on int', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'any_validation_source.dart',
      );
    });

    test('generates OneOf check with int literals', () {
      expect(
        output,
        contains('![42, 100].contains(code)'),
      );
    });
  });

  group('Validate.any with CustomRule on int', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'any_validation_source.dart',
      );
    });

    test('generates CustomRule static check call', () {
      expect(
        output,
        contains('!IsPositive.check(amount)'),
      );
    });

    test('uses rule name from CustomRule in error', () {
      expect(output, contains("'isPositive'"));
    });
  });

  group('Validate.any with AsyncCustomRule', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'any_validation_source.dart',
      );
    });

    test('generates async check with try/catch', () {
      expect(output, contains('try {'));
      expect(
        output,
        contains('!await IsEven.check(count)'),
      );
      expect(output, contains('} catch (e) {'));
    });

    test('throws on sync validate when async rules exist', () {
      expect(
        output,
        contains(
          "throw StateError('Async rules cannot be used with validate(). Use validateAsync() instead.');",
        ),
      );
    });
  });
}
