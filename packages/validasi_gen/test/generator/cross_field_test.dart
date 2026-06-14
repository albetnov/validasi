import 'basic_test.dart' show generateForSource;
import 'package:test/test.dart';

Future<void> main() async {
  group('Cross-field validation', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'cross_field_source.dart',
      );
    });

    test('generates CrossFields sealed class', () {
      expect(
          output,
          contains(
              'sealed class RegistrationCrossFields extends CrossFieldKey<Registration>'));
      expect(output,
          contains('static const RegistrationCrossFields confirmEmail'));
    });

    test('generates cross-field leaf class', () {
      expect(
          output,
          contains(
              'class _Registration_confirmEmail_CrossField extends RegistrationCrossFields'));
      expect(output, contains("super._('confirmEmail')"));
    });

    test('generates crossFieldKey override', () {
      expect(
          output, contains('CrossFieldKey<Registration> get crossFieldKey =>'));
      expect(output, contains('RegistrationCrossFields.confirmEmail'));
    });

    test('generates crossDependsOn with referenced fields', () {
      expect(output, contains('get crossDependsOn'));
      expect(output, contains('RegistrationFields.email'));
    });

    test('generates crossValidator with function call', () {
      expect(output, contains('get crossValidator'));
      expect(output, contains('final result = _checkEmailMatch(getField);'));
      expect(output, contains("rule: 'ValidateWith'"));
    });

    test('generates null cross overrides for fields without @ValidateWith', () {
      expect(output,
          contains('CrossFieldKey<Registration>? get crossFieldKey => null;'));
      expect(output, contains('get crossValidator => null;'));
      expect(output, contains('get crossDependsOn =>'));
      expect(
          output, contains('const <ValidasiField<Registration, dynamic>>{}'));
    });

    test('SimpleCross generates null cross overrides', () {
      expect(output,
          contains('CrossFieldKey<SimpleCross>? get crossFieldKey => null;'));
    });
  });

  group('Extension runs cross-field validators', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'cross_field_source.dart',
      );
    });

    test('generates dynamic? getField helper for cross-field extraction', () {
      expect(
        output,
        contains(
          'dynamic? getField<V>(ValidasiField<Registration, V> field) => field.extract(this);',
        ),
      );
    });

    test('looks up crossValidator for each cross-field annotated field', () {
      expect(
        output,
        contains(
          'final field = RegistrationFields.confirmEmail as ValidasiField<Registration, dynamic>;',
        ),
      );
      expect(
        output,
        contains(
          'final field = RegistrationFields.notes as ValidasiField<Registration, dynamic>;',
        ),
      );
      expect(output, contains('final cv = field.crossValidator;'));
      expect(output, contains('errors.addAll(cv(getField))'));
    });

    test('includes field with only @ValidateWith in fields class', () {
      expect(
          output,
          contains(
              'class RegistrationNotesField extends RegistrationFields<String?>'));
      expect(
        output,
        contains(
          'static const RegistrationFields<String?> notes = RegistrationNotesField();',
        ),
      );
    });
  });
}
