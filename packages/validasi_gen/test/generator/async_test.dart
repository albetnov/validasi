import 'basic_test.dart' show generateForSource;
import 'package:test/test.dart';

Future<void> main() async {
  group('Async inline rule', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'async_source.dart',
      );
    });

    test('sync validate throws when async rules exist', () {
      expect(
        output,
        contains(
          "throw StateError('Async rules cannot be used with validate(). Use validateAsync() instead.');",
        ),
      );
    });

    test('extension generates validateAsync method', () {
      expect(
        output,
        contains('Future<ValidasiResult<AsyncModel>> validateAsync()'),
      );
    });

    test('extension generates validateFieldAsync method', () {
      expect(
        output,
        contains(
          'Future<ValidasiResult<V>> validateFieldAsync<V>(AsyncModelFields<V> field)',
        ),
      );
    });

    test('async inline block uses try/catch and await', () {
      expect(output, contains('try {'));
      expect(output, contains('await _asyncCheck(value)'));
      expect(output, contains('} catch (e) {'));
      expect(output, contains("_Errors.inline([name], 'async_inline'"));
    });

    test('sync rules still emit MinLength check in validateAsync', () {
      expect(output, contains('if (value != null && value.length < 3)'));
    });
  });
}
