import 'package:test/test.dart';
import 'package:validasi/src/validasi.dart';
import 'package:validasi/src/engine/engine.dart';
import 'package:validasi/src/engine/rule.dart';
import 'package:validasi/src/engine/state.dart';

void main() {
  group('Validasi', () {
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
    });
  });
}

class _TestRule<T> extends Rule<T> {
  @override
  T? apply(T? value, ValidationState state) {
    // No-op test rule
    return value;
  }
}

class _CustomType {
  const _CustomType();
}
