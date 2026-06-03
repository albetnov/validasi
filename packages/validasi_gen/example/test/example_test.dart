import 'package:test/test.dart';

import '../lib/example.dart';

void main() {
  group('User validation', () {
    test('should pass for valid email', () {
      final user = User(email: 'test@example.com', tags: ['dart']);
      final result = user.validate();
      expect(result.isValid, isTrue);
      expect(result.data, same(user));
    });

    test('should fail for too short email', () {
      final user = User(email: 'ab', tags: ['dart']);
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['email']));
    });

    test('should fail for too long email', () {
      final longEmail = 'a' * 101;
      final user = User(email: longEmail, tags: ['dart']);
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MaxLength'));
    });

    test('should fail for empty tags', () {
      final user = User(email: 'test@example.com', tags: []);
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['tags']));
      expect(result.errors.first.message,
          equals('List must have at least 1 items'));
    });

    test('should pass for non-empty tags', () {
      final user = User(email: 'test@example.com', tags: ['a', 'b']);
      final result = user.validate();
      expect(result.isValid, isTrue);
    });
  });
}
