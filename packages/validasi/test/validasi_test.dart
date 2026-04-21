import 'package:test/test.dart';
import 'package:validasi/src/validasi.dart';
import 'package:validasi/src/engine/context.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/rule.dart';

void main() {
  group('Validasi', () {
    setUp(() {
      // Reset cache state before each test
      Validasi.withCache = true;
    });

    group('withCache', () {
      test('should default to true', () {
        expect(Validasi.withCache, isTrue);
      });

      test('should be configurable', () {
        Validasi.withCache = false;
        expect(Validasi.withCache, isFalse);

        Validasi.withCache = true;
        expect(Validasi.withCache, isTrue);
      });
    });

    group('withoutCache', () {
      test('should temporarily disable cache', () {
        Validasi.withCache = true;

        final result = Validasi.withoutCache(() {
          expect(Validasi.withCache, isFalse);
          return 42;
        });

        expect(result, equals(42));
        expect(Validasi.withCache, isTrue);
      });

      test('should restore previous state after execution', () {
        Validasi.withCache = false;

        Validasi.withoutCache(() {
          expect(Validasi.withCache, isFalse);
        });

        expect(Validasi.withCache, isFalse);
      });

      test('should restore state even on exception', () {
        Validasi.withCache = true;

        try {
          Validasi.withoutCache(() {
            throw Exception('Test exception');
          });
        } catch (e) {
          // Expected
        }

        expect(Validasi.withCache, isTrue);
      });

      test('should return callback result', () {
        final result = Validasi.withoutCache(() => 'test result');

        expect(result, equals('test result'));
      });

      test('should handle nested calls', () {
        Validasi.withCache = true;

        Validasi.withoutCache(() {
          expect(Validasi.withCache, isFalse);

          // Nested call should maintain false state
          Validasi.withoutCache(() {
            expect(Validasi.withCache, isFalse);
          });

          expect(Validasi.withCache, isFalse);
        });

        expect(Validasi.withCache, isTrue);
      });
    });

    group('string', () {
      test('should create string engine with no rules', () {
        final engine = Validasi.string();

        expect(engine, isA<ValidasiEngine<String, String>>());
        expect(engine.rules, isNull);
      });

      test('should create string engine with rules', () {
        final rule = _TestRule<String>();
        final engine = Validasi.string([rule]);

        expect(engine.rules?.length, equals(1));
        expect(engine.rules?.first, equals(rule));
      });

      test('should create engine with cache enabled', () {
        Validasi.withCache = true;
        final engine = Validasi.string();

        expect(engine.cacheEnabled, isTrue);
      });

      test('should create engine with cache disabled', () {
        Validasi.withCache = false;
        final engine = Validasi.string();

        expect(engine.cacheEnabled, isFalse);
      });
    });

    group('list', () {
      test('should create list engine with no rules', () {
        final engine = Validasi.list<int>();

        expect(engine, isA<ValidasiEngine<List<int>, List<int>>>());
        expect(engine.rules, isNull);
      });

      test('should create list engine with rules', () {
        final rule = _TestRule<List<int>>();
        final engine = Validasi.list<int>([rule]);

        expect(engine.rules?.length, equals(1));
        expect(engine.rules?.first, equals(rule));
      });

      test('should create engine with cache enabled', () {
        Validasi.withCache = true;
        final engine = Validasi.list<String>();

        expect(engine.cacheEnabled, isTrue);
      });

      test('should create engine with cache disabled', () {
        Validasi.withCache = false;
        final engine = Validasi.list<String>();

        expect(engine.cacheEnabled, isFalse);
      });
    });

    group('map', () {
      test('should create map engine with no rules', () {
        final engine = Validasi.map<String>();

        expect(engine,
            isA<ValidasiEngine<Map<String, String>, Map<String, String>>>());
        expect(engine.rules, isNull);
      });

      test('should create map engine with rules', () {
        final rule = _TestRule<Map<String, int>>();
        final engine = Validasi.map<int>([rule]);

        expect(engine.rules?.length, equals(1));
        expect(engine.rules?.first, equals(rule));
      });

      test('should create engine with cache enabled', () {
        Validasi.withCache = true;
        final engine = Validasi.map<dynamic>();

        expect(engine.cacheEnabled, isTrue);
      });

      test('should create engine with cache disabled', () {
        Validasi.withCache = false;
        final engine = Validasi.map<dynamic>();

        expect(engine.cacheEnabled, isFalse);
      });
    });

    group('number', () {
      test('should create number engine for int', () {
        final engine = Validasi.number<int>();

        expect(engine, isA<ValidasiEngine<int, int>>());
        expect(engine.rules, isNull);
      });

      test('should create number engine for double', () {
        final engine = Validasi.number<double>();

        expect(engine, isA<ValidasiEngine<double, double>>());
        expect(engine.rules, isNull);
      });

      test('should create number engine with rules', () {
        final rule = _TestRule<int>();
        final engine = Validasi.number<int>([rule]);

        expect(engine.rules?.length, equals(1));
        expect(engine.rules?.first, equals(rule));
      });

      test('should create engine with cache enabled', () {
        Validasi.withCache = true;
        final engine = Validasi.number<int>();

        expect(engine.cacheEnabled, isTrue);
      });

      test('should create engine with cache disabled', () {
        Validasi.withCache = false;
        final engine = Validasi.number<int>();

        expect(engine.cacheEnabled, isFalse);
      });
    });

    group('any', () {
      test('should create any engine with no rules', () {
        final engine = Validasi.any<String>();

        expect(engine, isA<ValidasiEngine<String, String>>());
        expect(engine.rules, isNull);
      });

      test('should create any engine with custom type', () {
        final engine = Validasi.any<_CustomType>();

        expect(engine, isA<ValidasiEngine<_CustomType, _CustomType>>());
      });

      test('should create any engine with rules', () {
        final rule = _TestRule<_CustomType>();
        final engine = Validasi.any<_CustomType>([rule]);

        expect(engine.rules?.length, equals(1));
        expect(engine.rules?.first, equals(rule));
      });

      test('should create engine with cache enabled', () {
        Validasi.withCache = true;
        final engine = Validasi.any<dynamic>();

        expect(engine.cacheEnabled, isTrue);
      });

      test('should create engine with cache disabled', () {
        Validasi.withCache = false;
        final engine = Validasi.any<dynamic>();

        expect(engine.cacheEnabled, isFalse);
      });
    });

    group('integration', () {
      test('should work with string validation', () {
        final engine = Validasi.string();

        final result = engine.validate('test');

        expect(result.isValid, isTrue);
        expect(result.data, equals('test'));
      });

      test('should work with list validation', () {
        final engine = Validasi.list<int>();

        final result = engine.validate([1, 2, 3]);

        expect(result.isValid, isTrue);
        expect(result.data, equals([1, 2, 3]));
      });

      test('should work with map validation', () {
        final engine = Validasi.map<String>();

        final result = engine.validate({'key': 'value'});

        expect(result.isValid, isTrue);
        expect(result.data, equals({'key': 'value'}));
      });

      test('should work with number validation', () {
        final engine = Validasi.number<int>();

        final result = engine.validate(42);

        expect(result.isValid, isTrue);
        expect(result.data, equals(42));
      });

      test('should respect withoutCache in factory methods', () {
        var callCount = 0;
        final rule = _CountingRule<String>(() => callCount++);

        Validasi.withoutCache(() {
          final engine = Validasi.string([rule]);

          engine.validate('test');
          engine.validate('test');

          expect(callCount, equals(2)); // No caching
        });
      });

      test('should respect global cache setting', () {
        var callCount = 0;
        final rule = _CountingRule<String>(() => callCount++);

        Validasi.withCache = true;
        final engine1 = Validasi.string([rule]);

        Validasi.withCache = false;
        final engine2 = Validasi.string([rule]);

        engine1.validate('test');
        engine1.validate('test');

        engine2.validate('test');
        engine2.validate('test');

        expect(callCount, equals(3)); // engine1: 1 call, engine2: 2 calls
      });
    });
  });
}

class _TestRule<T> extends Rule<T> {
  @override
  void apply(ValidationContext<T> context) {
    // No-op test rule
  }
}

class _CountingRule<T> extends Rule<T> {
  _CountingRule(this.onCall);

  final void Function() onCall;

  @override
  void apply(ValidationContext<T> context) {
    onCall();
  }
}

class _CustomType {
  const _CustomType();
}
