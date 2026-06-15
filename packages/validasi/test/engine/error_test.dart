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

    test('prefix should add prefix to empty path', () {
      final error = ValidationError(
        rule: 'testRule',
        message: 'Test message',
      );

      error.prefix('newPrefix');

      expect(error.rule, equals('testRule'));
      expect(error.message, equals('Test message'));
      expect(error.path, equals(['newPrefix']));
    });

    test('prefix should prepend to existing path', () {
      final error = ValidationError(
        rule: 'testRule',
        message: 'Test message',
        path: ['existing', 'path'],
      );

      error.prefix('newPrefix');

      expect(error.path, equals(['newPrefix', 'existing', 'path']));
    });

    test('prefix should preserve other properties', () {
      final error = ValidationError(
        rule: 'testRule',
        message: 'Test message',
        details: {'key': 'value'},
        path: ['existing'],
      );

      error.prefix('prefix');

      expect(error.rule, equals('testRule'));
      expect(error.message, equals('Test message'));
      expect(error.details, equals({'key': 'value'}));
    });

    test('prefix can be chained multiple times', () {
      final error = ValidationError(
        rule: 'testRule',
        message: 'Test message',
      );

      error
        ..prefix('first')
        ..prefix('second')
        ..prefix('third');

      expect(error.path, equals(['third', 'second', 'first']));
    });
  });
}
