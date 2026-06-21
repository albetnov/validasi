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
  group('indexedFields generation', () {
    late String output;

    setUpAll(() async {
      output = await generateForSource(
        'test/generator/src',
        'indexed_source.dart',
      );
    });

    test('generates indexedFields static method on sealed class', () {
      expect(
        output,
        contains(
          'static List<ValidasiField<FormType, dynamic>> indexedFields<FormType>',
        ),
      );
      expect(output, contains('String parentPath'));
      expect(output, contains('int index'));
    });

    test('includes IndexedField entries for each field', () {
      expect(output, contains('IndexedField<FormType, String>'));
      expect(output, contains("fieldName: 'name'"));
      expect(output, contains("fieldName: 'count'"));
    });

    test('generates validate/validateAsync delegations', () {
      expect(output, contains('StructNameField().validate(v)'));
      expect(output, contains('StructNameField().validateAsync(v)'));
      expect(output, contains('StructCountField().validate(v)'));
      expect(output, contains('StructCountField().validateAsync(v)'));
    });

    test('generates extractFromItem cast', () {
      expect(output, contains('(item as Struct).name'));
      expect(output, contains('(item as Struct).count'));
    });

    test('generates reconstructItem static method', () {
      expect(output, contains('static Struct reconstructItem<FormType>('));
      expect(output, contains('ValidasiFormController<FormType> ctrl'));
      expect(output, contains('ValidasiField<FormType, List<Struct>> field'));
      expect(output, contains('int index'));
    });

    test('reconstructItem reads sub-fields to construct object', () {
      expect(output, contains('ctrl.getArraySubField(field, index, \'name\')'));
      expect(
          output, contains('ctrl.getArraySubField(field, index, \'count\')'));
      expect(output, contains('return Struct('));
      expect(output, contains('name: ctrl.getValue('));
      expect(output, contains('count: ctrl.getValue('));
    });
  });
}
