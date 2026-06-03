import 'package:test/test.dart';
import 'package:validasi/src/engine/error.dart';

void main() {
  group('ValidationError', () {
    test('should create validation error with all properties', () {
      final error = ValidationError(
        rule: 'testRule',
        message: 'Test message',
        details: {'key': 'value'},
        path: ['field1', 'field2'],
      );

      expect(error.rule, equals('testRule'));
      expect(error.message, equals('Test message'));
      expect(error.details, equals({'key': 'value'}));
      expect(error.path, equals(['field1', 'field2']));
    });

    test('should create validation error with minimal properties', () {
      final error = ValidationError(
        rule: 'simpleRule',
        message: 'Simple message',
      );

      expect(error.rule, equals('simpleRule'));
      expect(error.message, equals('Simple message'));
      expect(error.details, isNull);
      expect(error.path, isNull);
    });

    test('withPrefix should add prefix to empty path', () {
      final error = ValidationError(
        rule: 'testRule',
        message: 'Test message',
      );

      final prefixed = error.withPrefix('newPrefix');

      expect(prefixed.rule, equals('testRule'));
      expect(prefixed.message, equals('Test message'));
      expect(prefixed.path, equals(['newPrefix']));
    });

    test('withPrefix should prepend prefix to existing path', () {
      final error = ValidationError(
        rule: 'testRule',
        message: 'Test message',
        path: ['existing', 'path'],
      );

      final prefixed = error.withPrefix('newPrefix');

      expect(prefixed.path, equals(['newPrefix', 'existing', 'path']));
    });

    test('withPrefix should preserve other properties', () {
      final error = ValidationError(
        rule: 'testRule',
        message: 'Test message',
        details: {'key': 'value'},
        path: ['existing'],
      );

      final prefixed = error.withPrefix('prefix');

      expect(prefixed.rule, equals('testRule'));
      expect(prefixed.message, equals('Test message'));
      expect(prefixed.details, equals({'key': 'value'}));
    });

    test('withPrefix can be chained multiple times', () {
      final error = ValidationError(
        rule: 'testRule',
        message: 'Test message',
      );

      final prefixed =
          error.withPrefix('first').withPrefix('second').withPrefix('third');

      expect(prefixed.path, equals(['third', 'second', 'first']));
    });
  });
}
