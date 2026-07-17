import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/generator.dart';

const _source = r'''
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

@ValidateClass()
class NameClashModel {
  @Validate<String>([Required()])
  final String name;

  const NameClashModel({required this.name});
}
''';

Future<String> _generate() async {
  final library = await resolveSource(
    _source,
    (resolver) async {
      final asset = AssetId('_resolve_source', 'lib/_resolve_source.dart');
      return resolver.libraryFor(asset);
    },
    readAllSourcesFromFilesystem: true,
  );
  return ValidasiGenerator(generateValidateFormDefault: true)
      .generate(LibraryReader(library), _MockBuildStep());
}

class _MockBuildStep implements BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('a field literally named "name"', () {
    late String output;

    setUpAll(() async {
      output = await _generate();
    });

    test(
        'gets a mangled static accessor to avoid colliding with '
        'FieldDescriptor.name', () {
      expect(
        output,
        contains(
            'static const NameClashModelFields<String> name_ = NameClashModelNameField();'),
      );
      expect(
        output,
        isNot(contains('static const NameClashModelFields<String> name =')),
      );
    });

    test('the leaf class still reports its real field name at runtime', () {
      expect(output, contains("String get name"));
      expect(output, contains("=> 'name';"));
    });

    test(
        'schema, validate(), and validateForm_X all reference the mangled '
        'accessor', () {
      expect(
        output,
        contains('reader.getValue(NameClashModelFields.name_) as String,'),
      );
      expect(
        output,
        contains(
            'NameClashModelFields.name_.validate(ctrl.getValue<String>(NameClashModelFields.name_))'),
      );
    });
  });
}
