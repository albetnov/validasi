import 'package:test/test.dart';

import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/handlers/one_of.dart';

void main() {
  group('OneOfGen', () {
    final gen = OneOfGen();

    test('name returns OneOf', () {
      expect(gen.name, equals('OneOf'));
    });

    group('check', () {
      test('generates correct condition with escaped strings', () {
        final info = RuleInfo(
            'OneOf',
            {
              'options': ["'a'", "'b'", "'c'"]
            },
            null);
        final condition = gen.check(info, 'fieldName');

        expect(
          condition,
          equals("fieldName != null && !['a', 'b', 'c'].contains(fieldName)"),
        );
      });

      test('handles single-quoted options', () {
        final info = RuleInfo(
            'OneOf',
            {
              'options': ["'it\\'s'", "'don\\'t'"]
            },
            null);
        final condition = gen.check(info, 'fieldName');

        expect(
          condition,
          equals(
            "fieldName != null && !['it\\'s', 'don\\'t'].contains(fieldName)",
          ),
        );
      });

      test('handles unquoted non-string options', () {
        final info = RuleInfo(
            'OneOf',
            {
              'options': ['Role.admin', 'Role.user']
            },
            null);
        final condition = gen.check(info, 'fieldName');

        expect(
          condition,
          equals(
            'fieldName != null && ![Role.admin, Role.user].contains(fieldName)',
          ),
        );
      });

      test('handles numeric options', () {
        final info = RuleInfo(
            'OneOf',
            {
              'options': ['42', '100']
            },
            null);
        final condition = gen.check(info, 'fieldName');

        expect(
          condition,
          equals('fieldName != null && ![42, 100].contains(fieldName)'),
        );
      });
    });

    group('defaultMessage', () {
      test('formats string options correctly', () {
        final info = RuleInfo(
            'OneOf',
            {
              'options': ["'red'", "'green'", "'blue'"]
            },
            null);
        final msg = gen.defaultMessage(info);

        expect(msg, equals('Value must be one of: red, green, blue'));
      });

      test('formats enum options correctly', () {
        final info = RuleInfo(
            'OneOf',
            {
              'options': ['Role.admin', 'Role.user']
            },
            null);
        final msg = gen.defaultMessage(info);

        expect(msg, equals('Value must be one of: Role.admin, Role.user'));
      });
    });

    group('emitError', () {
      test('generates correct error call', () {
        final info = RuleInfo(
            'OneOf',
            {
              'options': ["'a'", "'b'", "'c'"]
            },
            null);
        final call = gen.emitError(info, "['field']", '');
        expect(call, equals("_Errors.oneOf(['field'], ['a', 'b', 'c'])"));
      });

      test('includes custom message', () {
        final info = RuleInfo(
            'OneOf',
            {
              'options': ["'x'", "'y'"]
            },
            'Bad value');
        final call = gen.emitError(info, "['field']", ", message: 'Bad value'");
        expect(
            call,
            equals(
                "_Errors.oneOf(['field'], ['x', 'y'], message: 'Bad value')"));
      });
    });

    group('helperMethods', () {
      test('provides oneOf helper', () {
        expect(gen.helperMethods.keys, contains('oneOf'));
      });
    });
  });
}
