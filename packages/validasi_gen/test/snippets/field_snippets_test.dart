import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:validasi_gen/src/generators/field_snippets.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

const _source = r'''
import 'package:validasi_annotation/validasi_annotation.dart';

class TestModel {
  @Validate.string([Required(), MinLength(3)])
  final String name;

  @Validate.string([MinLength(5)])
  final String? bio;

  @Validate.string([Nullable()])
  final String? nickname;

  @Validate.string([MinLength(2, message: 'Custom msg')])
  final String alias;

  @Validate([Required()])
  final int age;

  const TestModel({
    required this.name,
    this.bio,
    this.nickname,
    required this.alias,
    required this.age,
  });
}
''';

const _snippets = FieldRuleSnippets();

FieldRules _fieldRulesFor(ClassElement cls, String fieldName) {
  final result = extractValidateFields(cls, LibraryReader(cls.library));
  return result.firstWhere((r) => r.field.name == fieldName);
}

void main() {
  late ClassElement testModel;

  setUpAll(() async {
    final library = await resolveSource(
      _source,
      (resolver) async {
        final asset = AssetId('_resolve_source', 'lib/_resolve_source.dart');
        return resolver.libraryFor(asset);
      },
      readAllSourcesFromFilesystem: true,
    );
    testModel = library.getClass('TestModel')!;
  });

  group('FieldRuleSnippets.emitInline', () {
    test('emits Required check before other rules', () {
      final ctx = _fieldRulesFor(testModel, 'name');
      final buf = StringBuffer();
      _snippets.emitInline(
        buf,
        ctx,
        indent: '  ',
        accessor: 'value',
        pathExpr: '[name]',
      );
      final output = buf.toString();

      expect(output, contains("_Errors.required("));
      expect(output, contains("_Errors.minLength("));

      final requiredIdx = output.indexOf("_Errors.required(");
      final minLengthIdx = output.indexOf("_Errors.minLength(");
      expect(requiredIdx, lessThan(minLengthIdx));
    });

    test('emits non-required rule with condition guard', () {
      final ctx = _fieldRulesFor(testModel, 'bio');
      final buf = StringBuffer();
      _snippets.emitInline(
        buf,
        ctx,
        indent: '  ',
        accessor: 'val',
        pathExpr: "['bio']",
      );
      final output = buf.toString();

      expect(output, contains('if (val != null && val.length < 5)'));
      expect(output, contains("_Errors.minLength("));
      expect(output, isNot(contains("_Errors.required(")));
    });

    test('skips Nullable rules', () {
      final ctx = _fieldRulesFor(testModel, 'nickname');
      final buf = StringBuffer();
      _snippets.emitInline(
        buf,
        ctx,
        indent: '  ',
        accessor: 'value',
        pathExpr: '[name]',
      );
      final output = buf.toString();

      expect(output, isNot(contains("rule: 'Nullable'")));
      expect(output.trim(), isEmpty);
    });

    test('uses custom message when provided', () {
      final ctx = _fieldRulesFor(testModel, 'alias');
      final buf = StringBuffer();
      _snippets.emitInline(
        buf,
        ctx,
        indent: '  ',
        accessor: 'value',
        pathExpr: '[name]',
      );
      final output = buf.toString();

      expect(output, contains("'Custom msg'"));
      expect(output, isNot(contains("'Minimum length is'")));
    });

    test('emits details for known rules', () {
      final ctx = _fieldRulesFor(testModel, 'bio');
      final buf = StringBuffer();
      _snippets.emitInline(
        buf,
        ctx,
        indent: '  ',
        accessor: 'value',
        pathExpr: '[name]',
      );
      final output = buf.toString();

      expect(output, contains("_Errors.minLength([name], 5"));
    });

    test('handles Required without other rules', () {
      final ctx = _fieldRulesFor(testModel, 'age');
      final buf = StringBuffer();
      _snippets.emitInline(
        buf,
        ctx,
        indent: '  ',
        accessor: 'value',
        pathExpr: '[name]',
      );
      final output = buf.toString();

      expect(output, contains("_Errors.required("));
      expect(output, contains('if (value == null)'));
    });
  });
}
