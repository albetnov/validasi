import 'basic_test.dart' show generateForSource;
import 'package:test/test.dart';

Future<void> main() async {
  group('generateFields: true (default)', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'generate_fields_source.dart',
      );
    });

    test('generates fields class', () {
      expect(output, contains('sealed class WithFieldsFields<V>'));
      expect(output, contains('static const WithFieldsFields<String> name'));
    });

    test('generates schema', () {
      expect(
          output,
          contains(
              'static const ValidasiSchema<WithFields> schema = _WithFieldsSchema();'));
      expect(
          output,
          contains(
              'class _WithFieldsSchema extends ValidasiSchema<WithFields>'));
    });

    test('generates validateField in extension', () {
      expect(
          output,
          contains(
              'ValidasiResult<V> validateField<V>(WithFieldsFields<V> field)'));
    });

    test('generates validate extension', () {
      expect(output, contains('extension \$WithFieldsValidasi on WithFields'));
    });
  });

  group('generateFields: false', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'generate_fields_source.dart',
      );
    });

    test('does not generate fields class', () {
      expect(output, isNot(contains('sealed class WithoutFieldsFields')));
      expect(output, isNot(contains('WithoutFieldsFields<')));
    });

    test('does not generate schema', () {
      expect(output, isNot(contains('ValidasiSchema<WithoutFields>')));
      expect(output, isNot(contains('_WithoutFieldsSchema')));
    });

    test('does not generate validateField for WithoutFields', () {
      expect(output,
          isNot(contains('validateField<V>(WithoutFieldsFields<V> field)')));
    });

    test('still generates validate extension', () {
      expect(output,
          contains('extension \$WithoutFieldsValidasi on WithoutFields'));
      expect(output, contains('ValidasiResult<WithoutFields> validate()'));
    });

    test('still generates field validation logic', () {
      expect(output, contains("rule: 'MinLength'"));
    });
  });
}
