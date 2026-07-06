import 'basic_test.dart' show generateForSource;
import 'package:test/test.dart';

Future<void> main() async {
  group('@RefineFn method-based cross-field validation', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'refine_source.dart',
      );
    });

    test('emits a local, uniquely-named \$fail closure in validate()', () {
      expect(
        output,
        contains(
          "\$fail_emailMustContainName = ({required String message, List<String> path = const []}) {",
        ),
      );
    });

    test('calls the refine method with named field args in validate()', () {
      expect(
        output,
        contains(
          'emailMustContainName(\$fail_emailMustContainName, name: name, email: email);',
        ),
      );
    });

    test('emits the refine call in validateAsync()', () {
      expect(
        output,
        contains(
          'emailMustContainName(\$fail_emailMustContainName, name: name, email: email);',
        ),
      );
    });

    test('does not emit cross-field keys or hooks', () {
      expect(output, isNot(contains('crossFieldKey')));
      expect(output, isNot(contains('crossValidator')));
      expect(output, isNot(contains('getField')));
    });
  });
}
