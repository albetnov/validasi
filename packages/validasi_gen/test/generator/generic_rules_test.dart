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
  late String output;

  setUpAll(() async {
    output = await generateForSource(
      'test/generator/src',
      'generic_rules_source.dart',
    );
  });

  test('generates Equals check', () {
    expect(output, contains("!= 'exact'"));
    expect(output, contains('_Errors.equals('));
  });

  test('generates NotEquals check', () {
    expect(output, contains("== 'forbidden'"));
    expect(output, contains('_Errors.notEquals('));
  });

  test('generates Having check without null guard', () {
    expect(
        output, contains('![Status.active, Status.inactive].contains('));
    expect(output, contains('_Errors.having('));
  });
}
