import 'package:test/test.dart';

import 'package:validasi_gen/src/handlers.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/handlers/min_length.dart';

void main() {
  group('MinLengthGen', () {
    final gen = MinLengthGen();

    test('name returns MinLength', () {
      expect(gen.name, equals('MinLength'));
    });

    group('check', () {
      test('generates correct condition for string', () {
        final info = RuleInfo('MinLength', {'length': 5}, null);
        final condition = gen.check(info, 'fieldName');

        expect(condition, equals('fieldName != null && fieldName.length < 5'));
      });

      test('generates correct condition for iterable', () {
        final info = RuleInfo('MinLength', {'length': 3}, null);
        final condition = gen.check(info, 'items');

        expect(condition, equals('items != null && items.length < 3'));
      });
    });

    group('defaultMessage', () {
      test('returns string message for default context', () {
        final info = RuleInfo('MinLength', {'length': 5}, null);
        final msg = gen.defaultMessage(info);

        expect(msg, equals('Minimum length is 5 characters'));
      });

      test('returns iterable message for iterable context', () {
        final info = RuleInfo('MinLength', {'length': 3}, null);
        final msg = gen.defaultMessage(info, FieldContext.iterable);

        expect(msg, equals('List must have at least 3 items'));
      });
    });

    group('emitError', () {
      test('generates string error call', () {
        final info = RuleInfo('MinLength', {'length': 5}, null);
        final call = gen.emitError(info, "['name']", '');
        expect(call, equals("_Errors.minLength(['name'], 5)"));
      });

      test('generates iterable error call', () {
        final info = RuleInfo('MinLength', {'length': 3}, null);
        final call =
            gen.emitError(info, "['items']", '', FieldContext.iterable);
        expect(call, equals("_Errors.itMinLength(['items'], 3)"));
      });

      test('includes custom message', () {
        final info = RuleInfo('MinLength', {'length': 5}, 'Too short');
        final call = gen.emitError(info, "['name']", ", message: 'Too short'");
        expect(call,
            equals("_Errors.minLength(['name'], 5, message: 'Too short')"));
      });
    });

    group('helperMethods', () {
      test('provides minLength and itMinLength helpers', () {
        expect(
            gen.helperMethods.keys, containsAll(['minLength', 'itMinLength']));
      });
    });
  });
}
