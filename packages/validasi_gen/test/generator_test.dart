import 'package:build/build.dart';
import 'package:test/test.dart';

import 'package:validasi_gen/src/builder.dart';
import 'package:validasi_gen/src/generator.dart';

void main() {
  group('ValidasiGenerator', () {
    test('detects @ValidateClass annotated classes', () {
      final generator = ValidasiGenerator();
      expect(generator.generateFieldsDefault, isTrue);
    });

    test('respects generateFieldsDefault option', () {
      final generator = ValidasiGenerator(generateFieldsDefault: false);
      expect(generator.generateFieldsDefault, isFalse);
    });
  });

  group('validasiBuilder', () {
    test('creates builder with correct extensions', () {
      final builder = validasiBuilder(BuilderOptions({}));
      expect(builder.buildExtensions, equals({'.dart': ['.g.dart']}));
    });
  });
}