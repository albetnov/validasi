import 'package:test/test.dart';
import 'package:validasi/src/exceptions/field_error.dart';
import 'package:validasi/src/mixins/strict_check.dart';
import 'package:validasi/src/result.dart';

import '../test_utils.dart';

class StrictCheckStub with StrictCheck<String> {
  @override
  final String? message;
  @override
  final bool strict;

  const StrictCheckStub(this.strict, {this.message});
}

void main() {
  group('Strict Check Test', () {
    test('strictCheck should throw FieldError when strict enabled', () {
      var stub = StrictCheckStub(true);

      expect(
          () => stub.strictCheck(10, 'path'),
          throwsA(predicate((e) =>
              e is FieldError &&
              e.name == 'invalidType' &&
              e.message == 'path is not a valid String')));
    });

    test('strictCheck should pass if value match type or null (strict)', () {
      var stub = StrictCheckStub(true);

      shouldNotThrow(() {
        stub.strictCheck('value', 'path');
        stub.strictCheck(null, 'path');
      });
    });

    test('strictCheck should be able to customize the type name', () {
      var stub = StrictCheckStub(true);

      expect(
          () => stub.strictCheck(10, 'field', type: 'other'),
          throwsA(predicate(
              (e) => e is FieldError && e.message.contains('other'))));
    });

    test('strictCheck should be able to customize the message', () {
      var stub = StrictCheckStub(true, message: ':name is not a valid text');

      expect(
          () => stub.strictCheck(10, 'example'),
          throwsA(predicate((e) =>
              e is FieldError && e.message == 'example is not a valid text')));
    });

    test('strictCheck should skip if strict set to false', () {
      var stub = StrictCheckStub(false);

      shouldNotThrow(() {
        stub.strictCheck('test', 'path');
      });
    });

    test('tryStrictCheck should bind FieldError to errors when strict enabled',
        () {
      var stub = StrictCheckStub(true);

      var result = Result();

      stub.tryStrictCheck(result, 20, 'path');

      expect(result.isValid, isFalse);
      expect(result.errors.map((e) => e.name), contains('invalidType'));
      expect(result.errors.firstOrNull?.message,
          equals('path is not a valid String'));
    });

    test('tryStrictCheck should pass when value match type or null (strict)',
        () {
      var stub = StrictCheckStub(true);

      var result = Result();

      stub.tryStrictCheck(result, 'value', 'path');
      stub.tryStrictCheck(result, null, 'path');

      expect(result.errors, isEmpty);
      expect(result.isValid, isTrue);
    });
  });
}
