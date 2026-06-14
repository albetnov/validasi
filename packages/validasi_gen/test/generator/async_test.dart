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
        contains('Future<ValidasiResult<AsyncModel>> validateAsync() async {'),
      );
    });

    test('extension generates validateFieldAsync method', () {
      expect(
        output,
        contains(
          'Future<ValidasiResult<V>> validateFieldAsync<V>(AsyncModelFields<V> field) async {',
        ),
      );
    });

    test('async inline block uses try/catch and await', () {
      expect(output, contains('try {'));
      expect(output, contains('await _asyncCheck(value)'));
      expect(output, contains('} catch (e) {'));
      expect(output, contains("rule: 'async_inline'"));
    });

    test('sync rules still emit MinLength check in validateAsync', () {
      expect(output, contains('if (value != null && value.length < 3)'));
    });
  });

  group('Async cross-field validator', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'async_source.dart',
      );
    });

    test('emits crossValidatorAsync override with await', () {
      expect(output, contains('get crossValidatorAsync {'));
      expect(output, contains('final result = await _checkMatch(getField);'));
      expect(
        output,
        contains("rule: 'ValidateWithAsync'"),
      );
    });

    test('extension awaits async cross validator in validateAsync', () {
      expect(
        output,
        contains('final cv = field.crossValidatorAsync;'),
      );
      expect(
        output,
        contains('\$errors.addAll(await cv(getField));'),
      );
    });
  });
}
