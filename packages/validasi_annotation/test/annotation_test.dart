import 'package:test/test.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

List<dynamic> _dummyValidator(dynamic get) => [];

void main() {
  group('ValidateClass', () {
    test('construct with defaults', () {
      const a = ValidateClass();
      expect(a.generateFields, isNull);
      expect(a.generateAssemble, isNull);
    });

    test('construct with explicit values', () {
      const a = ValidateClass(generateFields: true, generateAssemble: false);
      expect(a.generateFields, isTrue);
      expect(a.generateAssemble, isFalse);
    });
  });

  group('Validate', () {
    test('generic constructor', () {
      const a = Validate([Required()]);
      expect(a.rules, hasLength(1));
    });

    test('string constructor', () {
      const a = Validate.string([MinLength(3)]);
      expect(a.rules, hasLength(1));
    });

    test('iterable constructor', () {
      const a = Validate.iterable([MaxLength(10)]);
      expect(a.rules, hasLength(1));
    });

    test('nullable constructor arg', () {
      const a = Validate(null);
      expect(a.rules, isNull);
    });
  });

  group('RefineFn', () {
    test('construct with defaults', () {
      const a = RefineFn();
      expect(a.dependsOn, isEmpty);
    });

    test('construct with dependsOn', () {
      const a = RefineFn(dependsOn: ['name', 'email']);
      expect(a.dependsOn, ['name', 'email']);
    });
  });

  group('Rule subclasses', () {
    test('Required defaults', () {
      const r = Required();
      expect(r.message, isNull);
    });

    test('Required with message', () {
      const r = Required(message: 'Required field');
      expect(r.message, 'Required field');
    });

    test('MinLength', () {
      const r = MinLength(5);
      expect(r.length, 5);
      expect(r.message, isNull);
    });

    test('MaxLength', () {
      const r = MaxLength(100);
      expect(r.length, 100);
      expect(r.message, isNull);
    });

    test('OneOf', () {
      const r = OneOf(['a', 'b']);
      expect(r.options, ['a', 'b']);
      expect(r.message, isNull);
    });

    test('Nullable', () {
      const r = Nullable();
      expect(r.message, isNull);
    });

    test('AsyncInline', () {
      final r = AsyncInline(_dummyValidator, name: 'test_rule');
      expect(r.name, 'test_rule');
      expect(r.validator, isNotNull);
      expect(r.message, isNull);
    });

    test('AsyncInline with message', () {
      final r = AsyncInline(_dummyValidator, message: 'Custom');
      expect(r.message, 'Custom');
    });
  });

  group('ValidasiKey', () {
    test('can be extended', () {
      const key = _TestKey();
      expect(key, isA<ValidasiKey<String>>());
    });
  });
}

class _TestKey extends ValidasiKey<String> {
  const _TestKey();
}
