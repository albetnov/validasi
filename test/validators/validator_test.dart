import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/src/custom_rule.dart';
import 'package:validasi/src/exceptions/validasi_exception.dart';
import 'package:validasi/src/result.dart';
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

    test('parse should return success (success rule)', () {
      var stub = ValidatorStub()..addRuleTest('pass', true, 'should pass');

      shouldNotThrow(() {
        var result = stub.parse('value');
        expect(result.value, equals('value'));
        expect(result.errors, isEmpty);
        expect(result.isValid, isTrue);
      });
    });

    test('parse should throw FieldError on failing rule', () {
      var stub = ValidatorStub()
        ..addRuleTest('fail', false, ':name is failing')
        ..addRuleTest('success', true, 'should success');

      expect(() => stub.parse('value'),
          throwFieldError(name: 'fail', message: 'field is failing'));
    });

    test('parse should able to run custom rule', () {
      var stub = ValidatorStub().custom((value, fail) => true);

      shouldNotThrow(() {
        stub.parse('value');
      });

      stub.custom((value, fail) => false);

      expect(() => stub.parse('value'), throwFieldError(name: 'custom'));
    });

    test('parse should fail when trying to validate async custom rule', () {
      var stub = ValidatorStub();
      stub.custom((value, fail) async => true);

      expect(
          () => stub.parse('value'),
          throwsA(predicate((e) =>
              e is ValidasiException &&
              e.message ==
                  'The custom function require async context, please use `async` equivalent for parse.')));
    });

    test('parse should be able to validate multiple rules (in-order)', () {
      var stub = ValidatorStub()
        ..addRuleTest('rule1', true, 'msg')
        ..addRuleTest('rule2', false, 'msg')
        ..custom((value, fail) => false);

      expect(() => stub.parse('value'), throwFieldError(name: 'rule2'));

      var stub2 = ValidatorStub()
        ..addRuleTest('rule1', false, 'msg')
        ..addRuleTest('rule2', true, 'msg')
        ..custom((value, fail) => false);

      expect(() => stub2.parse('value'), throwFieldError(name: 'rule1'));

      var stub3 = ValidatorStub()
        ..addRuleTest('rule1', true, 'msg')
        ..addRuleTest('rule2', true, 'msg')
        ..custom((value, fail) => false);

      expect(() => stub3.parse('value'), throwFieldError(name: 'custom'));
    });

    test('parseAsync should be able to run async rule', () async {
      var stub = ValidatorStub().custom((value, fail) async => true);

      await shouldNotThrowAsync(() => stub.parseAsync('value'));

      stub.custom((value, fail) async => false);

      await expectLater(
          () => stub.parseAsync('value'), throwFieldError(name: 'custom'));
    });

    test('parseAsync should still be able to run non-async custom rule',
        () async {
      var stub = ValidatorStub().custom((value, fail) => false);

      await expectLater(() => stub.parseAsync('value'), throwFieldError());

      stub.custom((value, fail) => true);

      await shouldNotThrowAsync(() => stub.parseAsync('value'));
    });

    test('parseAsync should able to run normal rules', () async {
      var customRun = false;

      var stub = ValidatorStub()
        ..addRuleTest('name', true, 'message')
        ..addRuleTest('name2', false, 'message')
        ..custom((value, fail) {
          customRun = true;
          return false;
        });

      await expectLater(
          () => stub.parseAsync('value'), throwFieldError(name: 'name2'));

      expect(customRun, isFalse);
    });

    test('parseAsync should return success on passing rules', () async {
      var customRun = false;

      var stub = ValidatorStub()
        ..addRuleTest('name', true, 'message')
        ..addRuleTest('name2', true, 'message')
        ..custom((value, fail) {
          customRun = true;
          return true;
        });

      await shouldNotThrowAsync(() => stub.parseAsync('value'));
      expect(customRun, isTrue);
      var result = await stub.parseAsync('value');
      expect(result, isA<Result<String>>());
      expect(result.value, equals('value'));
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
  });
}
