import 'package:build/build.dart';
import 'package:source_gen_test/source_gen_test.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/generator.dart';

Future<String> generateForSource(String directory, String file) async {
  final reader = await initializeLibraryReaderForDirectory(directory, file);
  final generator = ValidasiGenerator();
  return generator.generate(reader, _MockBuildStep());
}

class _MockBuildStep implements BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> main() async {
  group('Simple class with @Validate.string', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'basic_source.dart',
      );
    });

    test('generates sealed fields class', () {
      expect(output,
          contains('sealed class SimpleFields<V> extends ValidasiKey<Simple>'));
      expect(
          output,
          contains(
              'static const SimpleFields<String> name = SimpleNameField();'));
    });

    test('generates leaf class with name and extract', () {
      expect(output,
          contains('class SimpleNameField extends SimpleFields<String>'));
      expect(output, contains("String get name"));
      expect(output, contains("'name'"));
      expect(output, contains('String extract(Simple owner)'));
      expect(output, contains('owner.name'));
    });

    test('generates validate with MinLength and MaxLength checks', () {
      expect(output, contains('if (value != null && value.length < 2)'));
      expect(output, contains("rule: 'MinLength'"));
      expect(output, contains('if (value != null && value.length > 50)'));
      expect(output, contains("rule: 'MaxLength'"));
    });

    test('generates assemble function', () {
      expect(output, contains('Simple assemble_Simple('));
      expect(output, contains('ctrl.getValue(SimpleFields.name) as String,'));
    });

    test('generates validate extension', () {
      expect(output, contains('extension \$SimpleValidasi on Simple'));
      expect(output, contains('ValidasiResult<Simple> validate()'));
      expect(
          output,
          contains(
              'ValidasiResult<V> validateField<V>(SimpleFields<V> field)'));
    });
  });

  group('Mixed types (String, int, iterable)', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'basic_source.dart',
      );
    });

    test('generates fields for annotated types only', () {
      expect(
          output,
          contains(
              'static const MixedFields<String> name = MixedNameField();'));
      expect(
          output,
          contains(
              'static const MixedFields<List<String>> tags = MixedTagsField();'));
    });

    test('skips fields without @Validate in fields class', () {
      expect(output, isNot(contains('MixedFields<int>')));
      expect(output, isNot(contains('MixedAgeField')));
    });

    test('generates iterable message for iterable context', () {
      expect(output, contains('List must have at least 1 items'));
    });
  });
}
