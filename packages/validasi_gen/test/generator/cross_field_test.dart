import 'basic_test.dart' show generateForSource;
import 'package:test/test.dart';

Future<void> main() async {
  group('Multi-field class', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'cross_field_source.dart',
      );
    });

    test('generates sealed fields class', () {
      expect(
          output,
          contains(
              'sealed class RegistrationFields<V> extends ValidasiKey<Registration>'));
      expect(
          output, contains('static const RegistrationFields<String> email ='));
      expect(output,
          contains('static const RegistrationFields<String> confirmEmail ='));
    });

    test('generates leaf classes for all annotated fields', () {
      expect(output, contains('class RegistrationEmailField extends'));
      expect(output, contains('class RegistrationConfirmEmailField extends'));
    });

    test('generates schema', () {
      expect(
          output,
          contains(
              'static const ValidasiSchema<Registration> schema = _RegistrationSchema();'));
      expect(
          output,
          contains(
              'class _RegistrationSchema extends ValidasiSchema<Registration>'));
      expect(output,
          contains('reader.getValue(RegistrationFields.email) as String,'));
      expect(
          output,
          contains(
              'reader.getValue(RegistrationFields.confirmEmail) as String,'));
    });

    test('generates validate extension', () {
      expect(
          output, contains('extension \$RegistrationValidasi on Registration'));
      expect(output, contains('ValidasiResult<Registration> validate()'));
    });

    test('SimpleCross generates its own fields class', () {
      expect(output, contains('sealed class SimpleCrossFields<V>'));
      expect(
          output, contains('extension \$SimpleCrossValidasi on SimpleCross'));
    });
  });
}
