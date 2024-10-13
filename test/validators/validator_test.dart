import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/transformers/transformer.dart';

import '../test_utils.dart';
import 'validator_test_stub.dart';
@GenerateNiceMocks([MockSpec<CustomRule>(), MockSpec<Transformer>()])
import 'validator_test.mocks.dart';

void main() {
  group('Validator Test', () {
    test('addRule should be able to add rule', () {
      List<Map<String, dynamic>> rules = [
        {'name': 'example', 'passing': false, 'message': 'not pass'},
        {'name': 'example2', 'passing': true, 'message': 'should pass'}
      ];

      var stub = ValidatorStub();

      for (var rule in rules) {
        stub.addRuleTest(rule['name'], rule['passing'], rule['message']);
      }

      expect(stub.rules, hasLength(2));

      for (var i = 0; i < rules.length; i++) {
        expect(stub.rules[i].name, equals(rules[i]['name']));
        expect(stub.rules[i].test('value'), equals(rules[i]['passing']));
        expect(stub.rules[i].message, equals(rules[i]['message']));
      }
    });

    test('custom should able to attach custom rule', () {
      var stub = ValidatorStub();

      stub.custom(
        (value, fail) {
          return fail('ups');
        },
      );

      expect(stub.customCallback, isNotNull);
      expect(
          stub.customCallback!(
            'value',
            (message) {
              expect(message, equals('ups'));
              return false;
            },
          ),
          isFalse);

      stub.custom(
        (value, fail) => fail('overriden'),
      );
    });

    test('custom should override custom rule if defined more than one', () {
      var stub = ValidatorStub().custom((value, fail) => fail('ups')).custom(
            (value, fail) => fail('overriden'),
          );

      stub.customCallback!(
        'value',
        (message) {
          expect(message, equals('overriden'));
          return false;
        },
      );
    });

    test('customFor should be able to attach custom rule from class', () {
      var stub = MockCustomRule<String>();

      when(stub.handle('value', any)).thenReturn(true);

      var validatorStub = ValidatorStub().customFor(stub);

      expect(validatorStub.customCallback, equals(stub.handle));
      validatorStub.customCallback!('value', (String message) => false);
      verify(stub.handle('value', any)).called(1);
    });

    test('runCustom should pass on running success rule', () {
      var stub = ValidatorStub().custom((value, fail) => true);

      shouldNotThrow(() {
        stub.runCustom('value', 'path');
      });
    });

    test('runCustom should pass when no custom rule attached', () {
      var stub = ValidatorStub();

      expect(stub.customCallback, isNull);

      shouldNotThrow(() {
        stub.runCustom('value', 'path');
      });
    });

    test('runCustom should fail on failing rule', () {
      var stub = ValidatorStub().custom((value, fail) => fail('ups'));

      expect(() => stub.runCustom('value', 'path'),
          throwFieldError(name: 'custom', message: 'ups', path: 'path'));
    });

    test('runCustom should able to parse :name on failing rule', () {
      var stub = ValidatorStub().custom((value, fail) => fail(':name'));

      expect(() => stub.runCustom('value', 'path'),
          throwFieldError(message: 'path'));
    });

    test('runCustom should throw ValidasiException running async custom rule',
        () {
      var stub = ValidatorStub().custom((value, fail) async => true);

      expect(
          () => stub.runCustom('value', 'path'),
          throwsA(predicate((e) =>
              e is ValidasiException &&
              e.message ==
                  'The custom function require async context, please use `async` equivalent for parse.')));
    });

    test('runCustomAsync should pass (success rule)', () async {
      var stub = ValidatorStub().custom((value, fail) async => true);

      await shouldNotThrowAsync(() => stub.runCustomAsync('value', 'path'));
    });

    test('runCustomAsync should be able to still validate non-async rule',
        () async {
      var stub = ValidatorStub().custom((value, fail) => true);

      await shouldNotThrowAsync(() => stub.runCustomAsync('value', 'path'));
    });

    test('runCustomAsync should return success when no custom rule attached',
        () async {
      var stub = ValidatorStub();

      expect(stub.customCallback, isNull);

      await shouldNotThrowAsync(() => stub.runCustomAsync('value', 'path'));
    });

    test('runCustomAsync should return default error message on fail',
        () async {
      var stub = ValidatorStub().custom((value, fail) async => false);

      await expectLater(
          () => stub.runCustomAsync('value', 'path'),
          throwFieldError(
              name: 'custom', path: 'path', message: 'path is not valid'));
    });

    test('runCustomAsync should return erorr message on fail', () async {
      var stub = ValidatorStub().custom((value, fail) async => fail('fail'));

      await expectLater(() => stub.runCustomAsync('value', 'path'),
          throwFieldError(message: 'fail'));
    });

    test('runCustomAsync should able to parse :name on failing rule', () async {
      var stub = ValidatorStub().custom((value, fail) async => fail(':name'));

      await expectLater(() => stub.runCustomAsync('value', 'path'),
          throwFieldError(message: 'path'));
    });

    test('tryParse should return success on passing rules', () {
      var stub = ValidatorStub()
        ..addRuleTest('name', true, 'message')
        ..addRuleTest('name2', true, 'message')
        ..custom((value, fail) => true);

      shouldNotThrow(() {
        var result = stub.tryParse('value');

        expect(result.value, 'value');
        expect(result.errors, isEmpty);
        expect(result.isValid, isTrue);
      });
    });

    test('tryParse should contains errors on failing rules', () {
      var stub = ValidatorStub()
        ..addRuleTest('name', false, 'message')
        ..addRuleTest('name2', false, 'message')
        ..custom((value, fail) => false);

      var result = stub.tryParse('value');

      expect(result.value, 'value');
      expect(result.errors, hasLength(3));
      expect(result.isValid, isFalse);
      expect(result.errors.map((e) => e.name).toList(),
          containsAllInOrder(['name', 'name2', 'custom']));
    });

    test('tryParse should contains formatted errors (:name) on failing rules',
        () {
      var stub = ValidatorStub()
        ..addRuleTest('name', false, ':name 1')
        ..addRuleTest('name2', false, ':name 2')
        ..custom((value, fail) => fail(':name 3'));

      var result = stub.tryParse('value', path: 'example');

      expect(result.errors.map((e) => e.message).toList(),
          containsAllInOrder(['example 1', 'example 2', 'example 3']));
    });

    test('tryParse should still throw ValidasiException on async custom rule',
        () {
      var stub = ValidatorStub()
        ..addRuleTest('name', false, 'message')
        ..custom((value, fail) async => false);

      expect(
          () => stub.tryParse('value'),
          throwsA(predicate((e) =>
              e is ValidasiException &&
              e.message ==
                  'The custom function require async context, please use `async` equivalent for parse.')));
    });

    test(
        'tryParseAsync should return success when validating success rules with custom async',
        () async {
      var stub = ValidatorStub()
        ..addRuleTest('name', true, 'message')
        ..addRuleTest('name2', true, 'message')
        ..custom((value, fail) async => true);

      var result = await stub.tryParseAsync('value');

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.value, 'value');
    });

    test('tryParseAsync should able to validate non-async custom rule',
        () async {
      var stub = ValidatorStub().custom((value, fail) => true);

      var result = await stub.tryParseAsync('value');

      expect(result.isValid, isTrue);

      stub.custom((value, fail) => false);

      var result2 = await stub.tryParseAsync('value');

      expect(result2.isValid, isFalse);
    });

    test('tryParseAsync should be able to format errors (:name)', () async {
      var stub = ValidatorStub()
        ..addRuleTest('name', false, ':name 1')
        ..addRuleTest('name2', false, ':name 2')
        ..custom((value, fail) async => fail(':name 3'));

      var result = await stub.tryParseAsync('value', path: 'example');

      expect(result.isValid, isFalse);
      expect(result.errors.map((e) => e.message).toList(),
          containsAll(['example 1', 'example 2', 'example 3']));
    });

    test('parse should be able to intercept errors and throw it immediately',
        () {
      var stub = ValidatorStub()
        ..addRuleTest('name', false, 'message')
        ..addRuleTest('name2', false, 'message')
        ..custom((value, fail) => false);

      expect(() => stub.parse('value'),
          throwFieldError(name: 'name', message: 'message'));

      stub = ValidatorStub()
        ..addRuleTest('name', true, 'message')
        ..addRuleTest('name2', false, 'message')
        ..custom((value, fail) => false);

      expect(() => stub.parse('value'),
          throwFieldError(name: 'name2', message: 'message'));
    });

    test('parse should be able to format errors (:name)', () {
      var stub = ValidatorStub()..addRuleTest('name', false, 'message :name');

      expect(
          () => stub.parse('value', path: 'example'),
          throwFieldError(
              name: 'name', message: 'message example', path: 'example'));
    });

    test('parse should be able to run custom', () {
      var stub = ValidatorStub().custom((value, fail) => true);

      shouldNotThrow(() {
        var result = stub.parse('value');

        expect(result.value, 'value');
        expect(result.errors, isEmpty);
        expect(result.isValid, isTrue);
      });

      stub = ValidatorStub().custom((value, fail) => false);

      expect(() => stub.parse('value'),
          throwFieldError(name: 'custom', message: 'field is not valid'));

      stub = ValidatorStub().custom((value, fail) => fail('ups'));

      expect(() => stub.parse('value'),
          throwFieldError(name: 'custom', message: 'ups'));

      stub = ValidatorStub().custom((value, fail) => fail(':name'));

      expect(() => stub.parse('value', path: 'example'),
          throwFieldError(name: 'custom', message: 'example'));

      stub = ValidatorStub().custom((value, fail) async => true);

      expect(() => stub.parse('value'), throwsA(predicate((e) {
        return e is ValidasiException &&
            e.message ==
                'The custom function require async context, please use `async` equivalent for parse.';
      })));
    });

    test('parseAsync should be able to run async custom', () async {
      var stub = ValidatorStub().custom((value, fail) async => true);

      var result = await stub.parseAsync('value');

      expect(result.value, 'value');
      expect(result.errors, isEmpty);
      expect(result.isValid, isTrue);

      stub = ValidatorStub().custom((value, fail) async => false);

      expect(() => stub.parseAsync('value'),
          throwFieldError(name: 'custom', message: 'field is not valid'));
    });

    test('can attach transformer and execute it', () async {
      var mock = MockTransformer<String>();

      when(mock.transform(1, any)).thenReturn('transformed');

      var stub = ValidatorStub(transformer: mock);

      var result = stub.parse(1);
      expect(result.value, equals('transformed'));

      result = stub.tryParse(1);
      expect(result.value, equals('transformed'));

      result = await stub.parseAsync(1);
      expect(result.value, equals('transformed'));

      result = await stub.tryParseAsync(1);
      expect(result.value, equals('transformed'));

      verify(mock.transform(1, any)).called(4);
    });

    test('can capture transformer error', () {
      var mock = MockTransformer<String>();

      var validator = ValidatorStub(transformer: mock);

      when(mock.transform(1, any))
          .thenAnswer((invoke) => invoke.positionalArguments[1]('error'));

      expect(() => validator.parse(1),
          throwFieldError(name: 'invalidType', message: 'error'));
    });

    test('can perform type check and throw error when no transformer supplied',
        () {
      var validator = ValidatorStub();

      expect(
          () => validator.parse(1),
          throwFieldError(
              name: 'invalidType',
              message: 'Expected type String. Got int instead.'));
    });

    test('should fail if null passed without nullable rule', () {
      var validator = ValidatorStub();

      expect(() => validator.parse(null),
          throwFieldError(name: 'required', message: 'field is required'));
    });

    test('should pass if null passed with nullable rule', () {
      var validator = ValidatorStub().nullable();

      shouldNotThrow(() {
        validator.parse(null);
      });
    });
  });
}
