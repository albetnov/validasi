import 'package:test/test.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/error.dart';

void main() {
  group('ValidationContext', () {
    test('should initialize with value', () {
      final context = ValidationContext<String>(value: 'test');

      expect(context.value, equals('test'));
      expect(context.errors, isEmpty);
      expect(context.isStopped, isFalse);
    });

    test('should initialize with null value', () {
      final context = ValidationContext<String>(value: null);

      expect(context.value, isNull);
      expect(context.errors, isEmpty);
      expect(context.isStopped, isFalse);
    });

    test('requireValue should return non-null value', () {
      final context = ValidationContext<String>(value: 'test');

      expect(context.requireValue, equals('test'));
    });

    test('requireValue should throw on null value', () {
      final context = ValidationContext<String>(value: null);

      expect(() => context.requireValue, throwsA(isA<TypeError>()));
    });

    test('setValue should update value', () {
      final context = ValidationContext<String>(value: 'initial');

      context.setValue('updated');

      expect(context.value, equals('updated'));
    });

    test('setValue should set value to null', () {
      final context = ValidationContext<String>(value: 'initial');

      context.setValue(null);

      expect(context.value, isNull);
    });

    test('stop should set isStopped to true', () {
      final context = ValidationContext<String>(value: 'test');

      expect(context.isStopped, isFalse);

      context.stop();

      expect(context.isStopped, isTrue);
    });

    test('addError should add error to errors list', () {
      final context = ValidationContext<String>(value: 'test');
      final error = ValidationError(rule: 'test', message: 'error');

      context.addError(error);

      expect(context.errors.length, equals(1));
      expect(context.errors.first, equals(error));
    });

    test('addError should add multiple errors', () {
      final context = ValidationContext<String>(value: 'test');
      final error1 = ValidationError(rule: 'test1', message: 'error1');
      final error2 = ValidationError(rule: 'test2', message: 'error2');
      final error3 = ValidationError(rule: 'test3', message: 'error3');

      context.addError(error1);
      context.addError(error2);
      context.addError(error3);

      expect(context.errors.length, equals(3));
      expect(context.errors[0], equals(error1));
      expect(context.errors[1], equals(error2));
      expect(context.errors[2], equals(error3));
    });

    test('should work with different types', () {
      final intContext = ValidationContext<int>(value: 42);
      expect(intContext.value, equals(42));

      final listContext = ValidationContext<List<String>>(value: ['a', 'b']);
      expect(listContext.value, equals(['a', 'b']));

      final mapContext = ValidationContext<Map<String, int>>(
        value: {'key': 123},
      );
      expect(mapContext.value, equals({'key': 123}));
    });

    test('should allow chaining operations', () {
      final context = ValidationContext<String>(value: 'test');
      final error = ValidationError(rule: 'test', message: 'error');

      context.setValue('new');
      context.addError(error);
      context.stop();

      expect(context.value, equals('new'));
      expect(context.errors.length, equals(1));
      expect(context.isStopped, isTrue);
    });
  });
}
