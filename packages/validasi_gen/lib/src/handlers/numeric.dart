import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class NumericGen extends RuleGen {
  static const _pattern = r'^[0-9]+$';

  @override
  String get name => 'Numeric';

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
    return RuleInfo('Numeric', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard!RegExp(${escapeDartString(_pattern)}).hasMatch($expr)';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.string]) =>
      'Must contain only digits';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.string]) =>
      '_Errors.numeric($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'numeric':
            "static ValidationError numeric(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Numeric',\n"
                "        message: message ?? 'Must contain only digits',\n"
                '        path: path,\n'
                '      );',
      };
}
