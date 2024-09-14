import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:validasi/validasi.dart';

import '../test_utils.dart';
import 'array_validator_test.mocks.dart';
import 'validator_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Validator>()])
void main() {
  group('Array Validator Test', () {
    test('passes strict check on value match num or null', () {
      var schema = Validasi.array(Validasi.string());

      shouldNotThrow(() {
        schema.parse(['a', 'b']);
        schema.parse(null);
      });
    });

    test('fails strict check on value not match array or not null', () {
      var schema = Validasi.array(Validasi.number());

      expect(
          () => schema.parse(true),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'invalidType' &&
              e.message == 'field is not a valid array')));

      var result = schema.tryParse(true);

      expect(result.isValid, isFalse);
      expect(getName(result), equals('invalidType'));
      expect(result.value, isNull);
    });

    test('can override message for type check', () {
      var schema =
          Validasi.array(Validasi.number(), message: 'Must array of numeric!');

      expect(getMsg(schema.tryParse(true)), 'Must array of numeric!');
    });

    test('parse can run custom callback and custom rule class', () {
      var schema = Validasi.array(Validasi.number()).custom((value, fail) {
        if (value?.contains(1) ?? false) {
          return fail(':name is already registered');
        }

        return true;
      });

      expect(
          () => schema.parse([1, 2, 3]),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'field is already registered')));

      shouldNotThrow(() => schema.parse([2, 3]));

      var mock = MockCustomRule<List<num>>();

      when(mock.handle(any, any)).thenAnswer((args) {
        if (args.positionalArguments[0].contains(1)) {
          return args.positionalArguments[1](':name is already registered');
        }

        return true;
      });

      schema.customFor(mock);

      expect(
          () => schema.parse([1, 2, 3]),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'field is already registered')));

      verify(mock.handle([1, 2, 3], any)).called(1);

      shouldNotThrow(() {
        schema.parse([2, 3]);
      });
    });

    test('parseAsync can also run custom rule', () async {
      var schema = Validasi.array(Validasi.number())
          .custom((value, fail) async => fail(':name are invalid'));

      await expectLater(
          () => schema.parseAsync([3, 5], path: 'ids'),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'custom' &&
              e.message == 'ids are invalid')));
    });

    test('tryParse can run custom rule', () {
      var schema = Validasi.array(Validasi.number())
          .custom((value, fail) => fail(':name contains invalid value'));

      var result = schema.tryParse([1, 2, 3], path: 'users');

      expect(result.isValid, isFalse);
      expect(getMsg(result), 'users contains invalid value');
    });

    test('tryParseAsync can also run custom rule', () async {
      var schema = Validasi.array(Validasi.number())
          .custom((value, fail) async => fail(':name contains invalid value'));

      var result = await schema.tryParseAsync([1, 2, 3], path: 'users');

      expect(result.isValid, isFalse);
      expect(getMsg(result), 'users contains invalid value');
    });

    test('should pass for required rule', () {
      var schema = Validasi.array(Validasi.number()).required();

      shouldNotThrow(() {
        schema.parse([1]);
        schema.parse([]);
      });
    });

    test('should fail for required rule', () {
      var schema = Validasi.array(Validasi.number()).required();

      expect(getName(schema.tryParse(null)), 'required');
    });

    test('can customize field name on required message', () {
      var schema = Validasi.array(Validasi.number()).required();

      expect(getMsg(schema.tryParse(null, path: 'ids')),
          equals('ids is required'));
    });

    test('can customize default error message on required', () {
      var schema = Validasi.array(Validasi.number())
          .required(message: 'where is ur array?');

      expect(getMsg(schema.tryParse(null)), equals('where is ur array?'));
    });

    test('verify the derived validator parse method got called', () async {
      var mock = MockValidator<int>();

      when(mock.parse(argThat(isA<int>()), path: anyNamed('path'))).thenAnswer(
        (realInvocation) =>
            Result(value: realInvocation.positionalArguments.first),
      );

      var schema = Validasi.array(mock);

      schema.parse([1, 2, 3]);

      verify(mock.parse(argThat(isA<int>()), path: anyNamed('path'))).called(3);

      when(mock.parseAsync(argThat(isA<int>()), path: anyNamed('path')))
          .thenAnswer(
        (realInvocation) async =>
            Result(value: realInvocation.positionalArguments.first),
      );

      await schema.parseAsync([1, 2, 3]);

      verify(mock.parseAsync(argThat(isA<int>()), path: anyNamed('path')))
          .called(3);
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
    });

    test('parse error should contain paths with index', () async {
      var schema = Validasi.array(Validasi.number());

      throwFieldError(() => schema.parse([1, 2, 'a']),
          name: 'invalidType', message: 'field.2 is not a valid number');

      expect(
          () => schema.parse([1, 2, 'a']),
          throwsA(
            predicate((e) => e is FieldError && e.path == 'field.2'),
          ));

      throwFieldError(() => schema.parse([1, 'a', 3]),
          name: 'invalidType', message: 'field.1 is not a valid number');

      throwFieldError(() => schema.parse(['a', 2, 3], path: 'sample'),
          name: 'invalidType', message: 'sample.0 is not a valid number');

      await expectLater(
        () => schema.parseAsync(['a', 1, 2]),
        throwsA(predicate((e) => e is FieldError && e.path == 'field.0')),
      );
    });

    test('tryParse error should contains paths with index', () async {
      var schema = Validasi.array(Validasi.number());

      var result = schema.tryParse([1, 2, 'a']);

      expect(result.isValid, isFalse);
      expect(result.errors.first.path, 'field.2');
      expect(getMsg(result), 'field.2 is not a valid number');

      expect(schema.tryParse([1, 'a', 3], path: 'sample').errors.first.path,
          'sample.1');

      result = schema.tryParse(['a', 'b', 3]);
      expect(result.errors.map((e) => e.path).toList(),
          containsAllInOrder(['field.0', 'field.1']));

      result = await schema.tryParseAsync(['a', 1, 2, 'c']);

      expect(result.errors.map((e) => e.path).toList(),
          containsAllInOrder(['field.0', 'field.3']));
    });

    test('parse could validate nested array', () {
      var schema = Validasi.array(
        Validasi.array(Validasi.number().required()).required(),
      );

      // shouldNotThrow(() {
      //   schema.parse([
      //     [
      //       [0]
      //     ]
      //   ]);
      // });

      schema.parse([]);

      // throwFieldError(() => schema.parse([]),
      // name: 'field.0.0', message: 'field.0.0 is required');
    });
  });
}
