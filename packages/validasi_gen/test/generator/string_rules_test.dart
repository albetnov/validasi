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
      'string_rules_source.dart',
    );
  });

  test('generates Alpha/Alphanumeric/Numeric checks', () {
    expect(output, contains('_Errors.alpha('));
    expect(output, contains('_Errors.alphanumeric('));
    expect(output, contains('_Errors.numeric('));
  });

  test('generates Lowercase/Uppercase checks', () {
    expect(output, contains('toLowerCase()'));
    expect(output, contains('toUpperCase()'));
  });

  test('generates StartsWith/EndsWith checks', () {
    expect(output, contains("startsWith('foo')"));
    expect(output, contains("endsWith('bar')"));
  });

  test('generates Regex check', () {
    expect(output, contains('RegExp('));
    expect(output, contains('_Errors.regex('));
  });

  test('generates Ulid check', () {
    expect(output, contains('_Errors.ulid('));
  });

  test('generates Uuid check with version extraction', () {
    expect(output, contains('_Errors.uuid('));
    expect(output, contains('radix: 16'));
  });

  test('generates Url check', () {
    expect(output, contains('Uri.tryParse('));
    expect(output, contains('_Errors.url('));
  });

  test('generates Ipv4/Ipv6/Ip checks', () {
    expect(output, contains('_Errors.ipv4('));
    expect(output, contains('_Errors.ipv6('));
    expect(output, contains('_Errors.ip('));
  });

  test('generates Email check', () {
    expect(output, contains('_Errors.email('));
    expect(output, contains("lastIndexOf('@')"));
  });

  test('generates Contains check for string context', () {
    expect(output, contains("contains('needle')"));
    expect(output, contains('_Errors.contains('));
  });
}
