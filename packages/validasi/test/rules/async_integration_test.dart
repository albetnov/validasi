import 'package:test/test.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

void main() {
  group('Async integration', () {
    test('should validate string with async inline rule', () async {
      final schema = Validasi.string([
        Rules.required(),
        Rules.inlineAsync((value) async => value != null && value.isNotEmpty),
      ]);

      final result = await schema.validateAsync('hello');

      expect(result.isValid, isTrue);
      expect(result.data, equals('hello'));
    });

    test('should fail string validation with async inline rule', () async {
      final schema = Validasi.string([
        Rules.inlineAsync(
          (value) async => false,
          message: 'Async check failed',
        ),
      ]);

      final result = await schema.validateAsync('hello');

      expect(result.isValid, isFalse);
      expect(result.errors.first.message, equals('Async check failed'));
    });

    test('should apply async transform in pipeline', () async {
      final schema = Validasi.string([
        Rules.transformAsync((value) async => value?.toUpperCase()),
        Rules.string.minLength(3),
      ]);

      final result = await schema.validateAsync('hello');

      expect(result.isValid, isTrue);
      expect(result.data, equals('HELLO'));
    });

    test('should validate map fields with async rules', () async {
      final schema = Validasi.map<dynamic>([
        Rules.map.hasFields({
          'email': FieldRules<Object?>([
            Rules.required(),
            Rules.string.email(),
            Rules.inlineAsync(
              (value) async => value == 'taken@example.com' ? false : true,
              message: 'Email already taken',
            ),
          ]),
        }),
      ]);

      final available = await schema.validateAsync({
        'email': 'free@example.com',
      });
      expect(available.isValid, isTrue);

      final taken = await schema.validateAsync({
        'email': 'taken@example.com',
      });
      expect(taken.isValid, isFalse);
      expect(taken.errors.first.path, equals(['email']));
      expect(taken.errors.first.message, equals('Email already taken'));
    });

    test('should validate list items with async rules', () async {
      final schema = Validasi.list<String>([
        Rules.iterable.forEach([
          Rules.inlineAsync(
            (value) async => value != null && value.isNotEmpty,
            message: 'Item must not be empty',
          ),
        ]),
      ]);

      final result = await schema.validateAsync(['a', '', 'c']);

      expect(result.isValid, isFalse);
      expect(result.errors.first.path, equals(['[1]']));
    });

    test('should validate map values with async rules', () async {
      final schema = Validasi.map<String>([
        Rules.map.allValues([
          Rules.inlineAsync(
            (value) async => value != null && value.length >= 3,
            message: 'Too short',
          ),
        ]),
      ]);

      final result = await schema.validateAsync({
        'a': 'hello',
        'b': 'hi',
      });

      expect(result.isValid, isFalse);
      expect(result.errors.first.path, equals(['b']));
    });

    test('should support async conditional field in map', () async {
      final schema = Validasi.map<String>([
        Rules.map.conditionalFieldAsync(
          'confirmPassword',
          (context, value) async {
            final password = context.get<String>('password');
            if (password != value) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ]);

      final match = await schema.validateAsync({
        'password': 'secret',
        'confirmPassword': 'secret',
      });
      expect(match.isValid, isTrue);

      final mismatch = await schema.validateAsync({
        'password': 'secret',
        'confirmPassword': 'wrong',
      });
      expect(mismatch.isValid, isFalse);
      expect(mismatch.errors.first.message, equals('Passwords do not match'));
    });

    test('should throw on sync validate when async rule is present', () {
      final schema = Validasi.string([
        Rules.inlineAsync((value) async => true),
      ]);

      expect(
        () => schema.validate('hello'),
        throwsStateError,
      );
    });

    test('should handle AnyOf with async rule sets', () async {
      final schema = Validasi.string([
        Rules.anyOf([
          [Rules.string.email()],
          [Rules.inlineAsync((value) async => value == 'special')],
        ]),
      ]);

      final emailResult = await schema.validateAsync('test@example.com');
      expect(emailResult.isValid, isTrue);

      final specialResult = await schema.validateAsync('special');
      expect(specialResult.isValid, isTrue);

      final failResult = await schema.validateAsync('neither');
      expect(failResult.isValid, isFalse);
    });
  });
}
