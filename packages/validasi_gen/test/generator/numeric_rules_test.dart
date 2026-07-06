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
      'numeric_rules_source.dart',
    );
  });

  test('generates Between check', () {
    expect(output, contains('< 1 || value > 10'));
    expect(output, contains('_Errors.between('));
  });

  test('generates LessThan/LessThanEqual checks', () {
    expect(output, contains('value >= 10'));
    expect(output, contains('value > 10'));
  });

  test('generates MoreThan/MoreThanEqual checks', () {
    expect(output, contains('value <= 1'));
    expect(output, contains('value < 1'));
  });

  test('generates Negative/NonNegative/NonPositive/Positive checks', () {
    expect(output, contains('_Errors.negative('));
    expect(output, contains('_Errors.nonNegative('));
    expect(output, contains('_Errors.nonPositive('));
    expect(output, contains('_Errors.positive('));
  });

  test('generates Finite check', () {
    expect(output, contains('!value.isFinite'));
    expect(output, contains('_Errors.finite('));
  });
}
