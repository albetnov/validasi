import 'package:test/test.dart';

import 'package:validasi_gen/src/handlers.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/handlers/max_length.dart';

void main() {
  group('MaxLengthGen', () {
    final gen = MaxLengthGen();

    test('name returns MaxLength', () {
      expect(gen.name, equals('MaxLength'));
    });

    group('check', () {
      test('generates correct condition for string', () {
        final info = RuleInfo('MaxLength', {'length': 5}, null);
        final condition = gen.check(info, 'fieldName');

        expect(condition, equals('fieldName != null && fieldName.length > 5'));
      });

      test('generates correct condition for iterable', () {
        final info = RuleInfo('MaxLength', {'length': 3}, null);
        final condition = gen.check(info, 'items');

        expect(condition, equals('items != null && items.length > 3'));
      });
    });

    group('defaultMessage', () {
      test('returns string message for default context', () {
        final info = RuleInfo('MaxLength', {'length': 5}, null);
        final msg = gen.defaultMessage(info);

        expect(msg, equals('Maximum length is 5 characters'));
      });

      test('returns iterable message for iterable context', () {
        final info = RuleInfo('MaxLength', {'length': 3}, null);
        final msg = gen.defaultMessage(info, FieldContext.iterable);

        expect(msg, equals('List must have at most 3 items'));
      });
    });

    group('emitError', () {
      test('generates string error call', () {
        final info = RuleInfo('MaxLength', {'length': 5}, null);
        final call = gen.emitError(info, "['name']", '');
        expect(call, equals("_Errors.maxLength(['name'], 5)"));
      });

      test('generates iterable error call', () {
        final info = RuleInfo('MaxLength', {'length': 3}, null);
        final call =
            gen.emitError(info, "['items']", '', FieldContext.iterable);
        expect(call, equals("_Errors.itMaxLength(['items'], 3)"));
      });

      test('includes custom message', () {
        final info = RuleInfo('MaxLength', {'length': 5}, 'Too long');
        final call = gen.emitError(info, "['name']", ", message: 'Too long'");
        expect(call,
            equals("_Errors.maxLength(['name'], 5, message: 'Too long')"));
      });
    });

    group('helperMethods', () {
      test('provides maxLength and itMaxLength helpers', () {
        expect(
            gen.helperMethods.keys, containsAll(['maxLength', 'itMaxLength']));
      });
    });
  });
}
