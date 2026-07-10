import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class UlidGen extends RuleGen {
  static const _pattern = r'^[0-7][0-9a-hjkmnp-z]{25}$';

  @override
  String get name => 'Ulid';

  @override
  Set<FieldContext> get supportedContexts => {FieldContext.string};

  @override
  void validateType(FieldContext context, FieldElement field) {
    if (!supportedContexts.contains(context)) {
      throw InvalidGenerationSourceError(
        "$name is not supported on type '${field.type.getDisplayString()}'. "
        'Supported: ${supportedContexts.map((c) => c.name)}',
        element: field,
      );
    }
  }

  @override
  RuleInfo parse(ConstantReader rule) {
    return RuleInfo('Ulid', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard!RegExp(${escapeDartString(_pattern)}, caseSensitive: false).hasMatch($expr)';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.string]) =>
      'Must be a valid ULID';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.string]) =>
      '_Errors.ulid($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'ulid':
            "static ValidationError ulid(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Ulid',\n"
                "        message: message ?? 'Must be a valid ULID',\n"
                '        path: path,\n'
                '      );',
      };
}
