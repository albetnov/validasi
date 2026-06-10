import 'package:test/test.dart';

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
        final msg = gen.defaultMessage(info, 'iterable');

        expect(msg, equals('List must have at most 3 items'));
      });
    });

    group('details', () {
      test('returns JSON with length', () {
        final info = RuleInfo('MaxLength', {'length': 5}, null);
        final details = gen.details(info);

        expect(details, equals("{'length': '5'}"));
      });
    });
  });
}
