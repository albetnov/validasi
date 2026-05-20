import 'package:test/test.dart';

import '../lib/example.dart';

void main() {
  group('User validation', () {
    test('should pass for valid email', () {
      final user = User(email: 'test@example.com');
      final result = user.validate();
      expect(result.isValid, isTrue);
      expect(result.data, same(user));
    });

    test('should fail for too short email', () {
      final user = User(email: 'ab');
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MinLength'));
      expect(result.errors.first.path, equals(['email']));
    });

    test('should fail for too long email', () {
      final longEmail = 'a' * 101;
      final user = User(email: longEmail);
      final result = user.validate();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.errors.first.rule, equals('MaxLength'));
    });
  });
}
