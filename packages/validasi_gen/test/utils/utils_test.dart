import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/utils.dart';

void main() {
  group('boolOption', () {
    test('returns null for null config', () {
      expect(boolOption(null, 'key'), isNull);
    });

    test('returns null for missing key', () {
      expect(boolOption({}, 'key'), isNull);
    });

    test('returns true for bool true value', () {
      expect(boolOption({'key': true}, 'key'), isTrue);
    });

    test('returns false for bool false value', () {
      expect(boolOption({'key': false}, 'key'), isFalse);
    });

    test('throws InvalidGenerationSourceError for non-bool value', () {
      expect(
        () => boolOption({'key': 'string'}, 'key'),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });

    test('throws InvalidGenerationSourceError for int value', () {
      expect(
        () => boolOption({'key': 42}, 'key'),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });

    test('throws for map value', () {
      expect(
        () => boolOption({'key': {}}, 'key'),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });
  });
}
