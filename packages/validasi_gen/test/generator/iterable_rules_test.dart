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
      'iterable_rules_source.dart',
    );
  });

  test('generates ExactLength check', () {
    expect(output, contains('.length != 3'));
    expect(output, contains('_Errors.exactLength('));
  });

  test('generates IsEmpty/IsNotEmpty checks', () {
    expect(output, contains('_Errors.isEmpty('));
    expect(output, contains('_Errors.isNotEmpty('));
  });

  test('generates Unique check', () {
    expect(output, contains('.toSet().length !='));
    expect(output, contains('_Errors.unique('));
  });

  test('generates ContainsAll check', () {
    expect(output, contains('.every('));
    expect(output, contains('_Errors.containsAll('));
  });

  test('generates NotContains check', () {
    expect(output, contains('_Errors.notContains('));
  });

  test('generates Contains check for iterable context', () {
    expect(output, contains('_Errors.itContains('));
  });
}
