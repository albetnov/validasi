import 'package:test/test.dart';
import 'package:validasi/src/transformer/validasi_transformation.dart';

void main() {
  group('ValidasiTransformation', () {
    test('should successfully transform value', () {
      final transformation = ValidasiTransformation<int, String>(
        (input) => 'Number: $input',
      );

      final result = transformation.tryTransform(42);

      expect(result.isValid, isTrue);
      expect(result.data, equals('Number: 42'));
      expect(result.error, isNull);
    });

    test('should transform with custom message', () {
      final transformation = ValidasiTransformation<int, String>(
        (input) => 'Number: $input',
        message: 'Custom message',
      );

      final result = transformation.tryTransform(42);

      expect(result.isValid, isTrue);
      expect(result.message, equals('Custom message'));
    });

    test('should catch exception and return error result', () {
      final transformation = ValidasiTransformation<String, int>(
        (input) => int.parse(input),
      );

      final result = transformation.tryTransform('not a number');

      expect(result.isValid, isFalse);
      expect(result.data, isNull);
      expect(result.error, isA<FormatException>());
      expect(result.message, equals('Failed to transform value'));
    });

    test('should use custom error message on exception', () {
      final transformation = ValidasiTransformation<String, int>(
        (input) => int.parse(input),
        message: 'Custom error message',
      );

      final result = transformation.tryTransform('not a number');

      expect(result.isValid, isFalse);
      expect(result.message, equals('Custom error message'));
    });

    test('should handle null values', () {
      final transformation = ValidasiTransformation<String?, int>(
        (input) => input == null ? 0 : int.parse(input),
      );

      final result = transformation.tryTransform(null);

      expect(result.isValid, isTrue);
      expect(result.data, equals(0));
    });

    test('should handle complex transformations', () {
      final transformation = ValidasiTransformation<List<int>, int>(
        (input) => input.reduce((a, b) => a + b),
      );

      final result = transformation.tryTransform([1, 2, 3, 4, 5]);

      expect(result.isValid, isTrue);
      expect(result.data, equals(15));
    });
  });

  group('ValidasiTransformationResult', () {
    test('success factory should create valid result', () {
      final result = ValidasiTransformationResult<String, int>.success(42);

      expect(result.isValid, isTrue);
      expect(result.data, equals(42));
      expect(result.error, isNull);
      expect(result.message, isNull);
    });

    test('success factory should accept custom message', () {
      final result = ValidasiTransformationResult<String, int>.success(
        42,
        message: 'Success message',
      );

      expect(result.isValid, isTrue);
      expect(result.data, equals(42));
      expect(result.message, equals('Success message'));
    });

    test('error factory should create invalid result', () {
      final error = Exception('Test error');
      final result = ValidasiTransformationResult<String, int>.error(error);

      expect(result.isValid, isFalse);
      expect(result.data, isNull);
      expect(result.error, equals(error));
      expect(result.message, isNull);
    });

    test('error factory should accept custom message', () {
      final error = Exception('Test error');
      final result = ValidasiTransformationResult<String, int>.error(
        error,
        message: 'Custom error message',
      );

      expect(result.isValid, isFalse);
      expect(result.error, equals(error));
      expect(result.message, equals('Custom error message'));
    });

    test('should create result with all properties', () {
      final result = ValidasiTransformationResult<String, int>(
        isValid: true,
        data: 100,
        error: null,
        message: 'Complete result',
      );

      expect(result.isValid, isTrue);
      expect(result.data, equals(100));
      expect(result.error, isNull);
      expect(result.message, equals('Complete result'));
    });

    test('should allow null data in valid result', () {
      final result = ValidasiTransformationResult<String, int?>(
        isValid: true,
        data: null,
      );

      expect(result.isValid, isTrue);
      expect(result.data, isNull);
    });
  });
}
