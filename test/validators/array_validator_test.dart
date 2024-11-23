import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';
import 'validator_test_stub.mocks.dart';

@GenerateNiceMocks([MockSpec<Validator>()])
void main() {
  group('Array Validator Test', () {
    test('passes type check on value match array', () {
      var schema = Validasi.array(Validasi.string());

      shouldNotThrow(() {
        schema.parse(['a', 'b']);
      });
    });

    test('fails types check on value not match array', () {
      var schema = Validasi.array(Validasi.number());

      expect(
          () => schema.parse(true),
          throwFieldError(
              name: 'invalidType',
              message: 'Expected type List<dynamic>. Got bool instead.'));

      var result = schema.tryParse(true);

      expect(result.isValid, isFalse);
      expect(getName(result), equals('invalidType'));
      expect(result.value, isNull);
    });

    test('should pass if nullable is set for value null', () {
      var schema = Validasi.array(Validasi.string()).nullable();

      expect(schema.tryParse(null).isValid, isTrue);

      var nestedSchema =
          Validasi.array(Validasi.array(Validasi.string()).nullable());

      shouldNotThrow(() {
        nestedSchema.parse([null]);
      });
    });

    test('should fail if nullable is not set for value null', () {
      var schema = Validasi.array(Validasi.string());

      var result = schema.tryParse(null);

      expect(getName(result), equals('required'));
      expect(getMsg(result), equals('field is required'));

      var nestedSchema = Validasi.array(Validasi.array(Validasi.string()));

      expect(
          () => nestedSchema.parse([null]),
          throwFieldError(
            name: 'required',
            message: 'field.0 is required',
            path: 'field.0',
          ));
    });

    test('verify can attach custom', () async {
      await testCanAttachCustom(
        valid: [8, 9, 10],
        invalid: [1, 2, 3],
        validator: () => Validasi.array(Validasi.number()),
      );
    });

    test('verify the derived validator tryParse method got called', () async {
      var mock = MockValidator<int>();

      when(mock.tryParse(argThat(isA<int>()), path: anyNamed('path')))
          .thenAnswer(
        (realInvocation) =>
            Result(value: realInvocation.positionalArguments.first),
      );

      var schema = Validasi.array(mock);

      schema.tryParse([1, 2, 3]);

      verify(mock.tryParse(argThat(isA<int>()), path: anyNamed('path')))
          .called(3);

      when(mock.tryParseAsync(argThat(isA<int>()), path: anyNamed('path')))
          .thenAnswer(
        (realInvocation) async =>
            Result(value: realInvocation.positionalArguments.first),
      );

      await schema.tryParseAsync([1, 2, 3]);

      verify(mock.tryParseAsync(argThat(isA<int>()), path: anyNamed('path')))
          .called(3);

      schema.parse([1, 2, 3]);

      verify(mock.tryParse(argThat(isA<int>()), path: anyNamed('path')))
          .called(3);

      await schema.parseAsync([1, 2, 3]);

      verify(mock.tryParseAsync(argThat(isA<int>()), path: anyNamed('path')))
          .called(3);
    });

    test('parse error should contain paths with index', () async {
      var schema = Validasi.array(Validasi.number());

      expect(
          () => schema.parse([1, 2, 'a']),
          throwFieldError(
              name: 'invalidType',
              message: 'Expected type num. Got String instead.'));

      expect(() => schema.parse([1, 2, 'a']), throwFieldError(path: 'field.2'));

      expect(
          () => schema.parse([1, 'a', 3]),
          throwFieldError(
              name: 'invalidType',
              message: 'Expected type num. Got String instead.'));

      expect(
          () => schema.parse(['a', 2, 3], path: 'sample'),
          throwFieldError(
              name: 'invalidType',
              message: 'Expected type num. Got String instead.'));

      await expectLater(() => schema.parseAsync(['a', 1, 2]),
          throwFieldError(path: 'field.0'));
    });

    test('tryParse error should contains paths with index', () async {
      var schema = Validasi.array(Validasi.number());

      var result = schema.tryParse([1, 2, 'a']);

      expect(result.isValid, isFalse);
      expect(getPath(result), 'field.2');
      expect(getMsg(result), 'Expected type num. Got String instead.');

      expect(schema.tryParse([1, 'a', 3], path: 'sample').errors.first.path,
          'sample.1');

      result = schema.tryParse(['a', 'b', 3]);
      expect(result.errors.map((e) => e.path).toList(),
          containsAllInOrder(['field.0', 'field.1']));

      result = await schema.tryParseAsync(['a', 1, 2, 'c']);

      expect(result.errors.map((e) => e.path).toList(),
          containsAllInOrder(['field.0', 'field.3']));
    });

    test('parse could validate nested array', () async {
      var schema = Validasi.array(
        Validasi.array(Validasi.number()),
      );

      expect(
          () => schema.parse([
                [null]
              ]),
          throwFieldError(
              name: 'required',
              path: 'field.0.0',
              message: 'field.0.0 is required'));

      shouldNotThrow(() {
        schema.parse([
          [1]
        ]);
      });

      await expectLater(
          () => schema.parseAsync([
                [null]
              ]),
          throwFieldError(
              name: 'required',
              path: 'field.0.0',
              message: 'field.0.0 is required'));

      await shouldNotThrowAsync(() => schema.parseAsync([
            [1]
          ]));
    });

    test('tryParse could validate nested array', () async {
      var schema = Validasi.array(
        Validasi.array(Validasi.number()),
      );

      var result = schema.tryParse([
        [null]
      ]);

      expect(result.isValid, isFalse);
      expect(getPath(result), 'field.0.0');
      expect(getMsg(result), 'field.0.0 is required');

      result = schema.tryParse([
        [1]
      ]);

      expect(result.isValid, isTrue);

      result = await schema.tryParseAsync([
        [null]
      ]);

      expect(result.isValid, isFalse);
      expect(getPath(result), 'field.0.0');
      expect(getMsg(result), 'field.0.0 is required');

      result = await schema.tryParseAsync([
        [1]
      ]);

      expect(result.isValid, isTrue);
    });

    test('parse and tryParse reconstruct array correctly', () async {
      var schema =
          Validasi.array(Validasi.number(transformer: NumberTransformer()));

      var result = schema.parse(['1', '2', '3']);

      expect(result.value, equals([1, 2, 3]));

      result = await schema.parseAsync(['1', '2', '3']);

      await expectLater(result.value, equals([1, 2, 3]));

      var scenarios = [
        {
          'case': ['123', '456', true, '789'],
          'expected': [123, 456, null, 789]
        },
        {
          'case': ['123', '456', 'true', '789'],
          'expected': [123, 456, null, 789]
        },
        {
          'case': ['123', '456'],
          'expected': [123, 456]
        }
      ];

      for (var scenario in scenarios) {
        result = schema.tryParse(scenario['case']);

        expect(result.value, equals(scenario['expected']));

        result = await schema.tryParseAsync(scenario['case']);

        expect(result.value, equals(scenario['expected']));
      }
    });
  });

  test('should pass for min', () {
    var schema = Validasi.array(Validasi.number()).min(3);

    expect(schema.tryParse([1, 2, 3]).isValid, isTrue);
    expect(schema.tryParse([1, 2, 3, 4]).isValid, isTrue);
  });

  test('should fail for min', () {
    var schema = Validasi.array(Validasi.number()).min(3);

    expect(schema.tryParse([1, 2]).isValid, isFalse);
    expect(getMsg(schema.tryParse([1, 2])), 'field must have at least 3 items');
  });

  test('can customize field name on min message', () {
    var schema = Validasi.array(Validasi.number()).min(3);

    expect(getMsg(schema.tryParse([1, 2], path: 'label')),
        'label must have at least 3 items');
  });

  test('can customize message on min', () {
    var schema = Validasi.array(Validasi.number())
        .min(3, message: ':name should have 3 items');

    expect(getMsg(schema.tryParse([1, 2], path: 'cart')),
        'cart should have 3 items');
  });

  test('should pass for max', () {
    var schema = Validasi.array(Validasi.number()).max(3);

    expect(schema.tryParse([1, 2, 3]).isValid, isTrue);
    expect(schema.tryParse([1, 2]).isValid, isTrue);
  });

  test('should fail for max', () {
    var schema = Validasi.array(Validasi.number()).max(3);

    expect(schema.tryParse([1, 2, 3, 4]).isValid, isFalse);
    expect(getMsg(schema.tryParse([1, 2, 3, 4])),
        'field must have at most 3 items');
  });

  test('can customize field name on max message', () {
    var schema = Validasi.array(Validasi.number()).max(3);

    expect(getMsg(schema.tryParse([1, 2, 3, 4], path: 'label')),
        'label must have at most 3 items');
  });

  test('can customize message on max', () {
    var schema = Validasi.array(Validasi.number())
        .max(3, message: ':name should have 3 items');

    expect(getMsg(schema.tryParse([1, 2, 3, 4], path: 'cart')),
        'cart should have 3 items');
  });

  test('should pass for notContains', () {
    var schema = Validasi.array(Validasi.number()).notContains([4, 5]);

    expect(schema.tryParse([1, 2, 3]).isValid, isTrue);
  });

  test('should fail for notContains', () {
    var schema = Validasi.array(Validasi.number()).notContains([4, 5]);

    expect(schema.tryParse([1, 2, 3, 4]).isValid, isFalse);
    expect(
        getMsg(schema.tryParse([1, 2, 3, 4])), 'field must not contain [4, 5]');
  });

  test('can customize field name on notContains message', () {
    var schema = Validasi.array(Validasi.number()).notContains([4, 5]);

    expect(getMsg(schema.tryParse([1, 2, 3, 4], path: 'label')),
        'label must not contain [4, 5]');
  });

  test('can customize message on notContains', () {
    var schema = Validasi.array(Validasi.number())
        .notContains([4, 5], message: ':name should not contain [4, 5]');

    expect(getMsg(schema.tryParse([1, 2, 3, 4], path: 'cart')),
        'cart should not contain [4, 5]');
  });

  test('should pass for contains', () {
    var schema = Validasi.array(Validasi.number()).contains([1, 2]);

    expect(schema.tryParse([1, 2]).isValid, isTrue);
    expect(schema.tryParse([1]).isValid, isTrue);
  });

  test('should fail for contains', () {
    var schema = Validasi.array(Validasi.number()).contains([1, 2]);

    expect(schema.tryParse([1, 3]).isValid, isFalse);
    expect(getMsg(schema.tryParse([1, 3])), 'field must contain [1, 2]');
  });

  test('can customize field name on contains message', () {
    var schema = Validasi.array(Validasi.number()).contains([1, 2]);

    expect(getMsg(schema.tryParse([1, 3], path: 'label')),
        'label must contain [1, 2]');
  });

  test('can customize message on contains', () {
    var schema = Validasi.array(Validasi.number())
        .contains([1, 2], message: ':name should contain [1, 2]');

    expect(getMsg(schema.tryParse([1, 3], path: 'cart')),
        'cart should contain [1, 2]');
  });

  test('should pass for unique', () {
    var schema = Validasi.array(Validasi.number()).unique();

    expect(schema.tryParse([1, 2, 3]).isValid, isTrue);
  });

  test('should fail for unique', () {
    var schema = Validasi.array(Validasi.number()).unique();

    expect(schema.tryParse([1, 2, 1]).isValid, isFalse);
    expect(
        getMsg(schema.tryParse([1, 2, 1])), 'field must contain unique items');
  });

  test('can customize message on unique', () {
    var schema =
        Validasi.array(Validasi.number()).unique(message: 'unique only');

    expect(getMsg(schema.tryParse([1, 2, 1])), 'unique only');
  });

  test('can customize field name on unique message', () {
    var schema = Validasi.array(Validasi.number()).unique();

    expect(getMsg(schema.tryParse([1, 2, 1], path: 'label')),
        'label must contain unique items');
  });
}
