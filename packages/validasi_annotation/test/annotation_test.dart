import 'package:test/test.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

List<dynamic> _dummyValidator(dynamic get) => [];
bool _syncCheck(dynamic value) => true;

void main() {
  group('ValidateClass', () {
    test('construct with defaults', () {
      const a = ValidateClass();
      expect(a.generateFields, isNull);
      expect(a.generateSchema, isNull);
    });

    test('construct with explicit values', () {
      const a = ValidateClass(generateFields: true, generateSchema: false);
      expect(a.generateFields, isTrue);
      expect(a.generateSchema, isFalse);
    });
  });

  group('Validate', () {
    test('generic constructor', () {
      const a = Validate([Required()]);
      expect(a.rules, hasLength(1));
    });

    test('string typed constructor', () {
      const a = Validate<String>([MinLength(3)]);
      expect(a.rules, hasLength(1));
    });

    test('iterable typed constructor', () {
      const a = Validate<List<String>>([MaxLength(10)]);
      expect(a.rules, hasLength(1));
    });

    test('typed constructor', () {
      const a = Validate<int>([Required()]);
      expect(a.rules, hasLength(1));
    });

    test('empty rules list', () {
      const a = Validate<String>([]);
      expect(a.rules, isEmpty);
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

    test('CustomRule defaults', () {
      const r = _CustomRuleImpl(name: 'test');
      expect(r.name, 'test');
      expect(r.message, isNull);
      expect(r.runOnNull, isFalse);
    });

    test('CustomRule with message', () {
      const r = _CustomRuleImpl(name: 'test', message: 'Custom');
      expect(r.message, 'Custom');
    });

    test('CustomRule with runOnNull', () {
      const r = _CustomRuleImpl(name: 'test', runOnNull: true);
      expect(r.runOnNull, isTrue);
    });

    test('AsyncCustomRule defaults', () {
      const r = _AsyncCustomRuleImpl(name: 'test');
      expect(r.name, 'test');
      expect(r.message, isNull);
      expect(r.runOnNull, isFalse);
    });

    test('Inline defaults', () {
      const r = Inline(_syncCheck);
      expect(r.name, 'inline');
      expect(r.message, isNull);
      expect(r.runOnNull, isFalse);
      expect(r.validator, isNotNull);
    });

    test('Inline with custom name and message', () {
      const r = Inline(_syncCheck,
          name: 'custom', message: 'Bad value', runOnNull: true);
      expect(r.name, 'custom');
      expect(r.message, 'Bad value');
      expect(r.runOnNull, isTrue);
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

class _CustomRuleImpl extends CustomRule<String> {
  const _CustomRuleImpl({
    required super.name,
    super.message,
    super.runOnNull,
  });
}

class _AsyncCustomRuleImpl extends AsyncCustomRule<String> {
  const _AsyncCustomRuleImpl({
    required super.name,
  });
}
