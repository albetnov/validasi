import 'basic_test.dart' show generateForSource;
import 'package:test/test.dart';

Future<void> main() async {
  group('Custom error messages', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'custom_message_source.dart',
      );
    });

    test('uses custom message for MinLength', () {
      expect(output, contains("message: 'Name too short'"));
      expect(output, isNot(contains("'Minimum length is 3 characters'")));
    });

    test('uses custom message for MaxLength', () {
      expect(output, contains("message: 'Name too long'"));
      expect(output, isNot(contains("'Maximum length is 50 characters'")));
    });

    test('still includes rule name and details', () {
      expect(output, contains("_Errors.minLength("));
      expect(output, contains("_Errors.minLength([name], 3"));
    });

    test('uses custom message for OneOf', () {
      expect(output, contains("message: 'Must be a valid color'"));
      expect(output, isNot(contains("'Value must be one of:'")));
    });
  });
}
