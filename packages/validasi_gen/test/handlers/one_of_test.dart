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
        final info = RuleInfo('OneOf', {'options': ['a', 'b', 'c']}, null);
        final condition = gen.check(info, 'fieldName');

        expect(
          condition,
          equals("fieldName != null && !['a', 'b', 'c'].contains(fieldName)"),
        );
      });

      test('escapes single quotes in options', () {
        final info = RuleInfo('OneOf', {'options': ["it's", "don't"]}, null);
        final condition = gen.check(info, 'fieldName');

        expect(
          condition,
          equals(
            "fieldName != null && !['it\\'s', 'don\\'t'].contains(fieldName)",
          ),
        );
      });

      test('escapes backslashes in options', () {
        final info = RuleInfo('OneOf', {'options': ['path\\to\\file']}, null);
        final condition = gen.check(info, 'fieldName');

        expect(
          condition,
          equals(
            "fieldName != null && !['path\\\\to\\\\file'].contains(fieldName)",
          ),
        );
      });

      test('escapes newlines in options', () {
        final info = RuleInfo('OneOf', {'options': ['line1\nline2']}, null);
        final condition = gen.check(info, 'fieldName');

        expect(
          condition,
          equals(
            "fieldName != null && !['line1\\nline2'].contains(fieldName)",
          ),
        );
      });

      test('escapes dollar signs in options', () {
        final info = RuleInfo('OneOf', {'options': ['price\$100']}, null);
        final condition = gen.check(info, 'fieldName');

        expect(
          condition,
          equals(
            r"fieldName != null && !['price\$100'].contains(fieldName)",
          ),
        );
      });
    });

    group('defaultMessage', () {
      test('formats options correctly', () {
        final info = RuleInfo('OneOf', {'options': ['red', 'green', 'blue']}, null);
        final msg = gen.defaultMessage(info);

        expect(msg, equals('Value must be one of: red, green, blue'));
      });

      test('handles single option', () {
        final info = RuleInfo('OneOf', {'options': ['only']}, null);
        final msg = gen.defaultMessage(info);

        expect(msg, equals('Value must be one of: only'));
      });
    });

    group('details', () {
      test('returns null', () {
        final info = RuleInfo('OneOf', {'options': ['a', 'b']}, null);
        expect(gen.details(info), isNull);
      });
    });
  });
}