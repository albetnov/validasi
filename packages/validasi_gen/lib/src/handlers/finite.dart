import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class FiniteGen extends RuleGen {
  @override
  String get name => 'Finite';

  @override
  Set<FieldContext> get supportedContexts => {FieldContext.generic};

  @override
  void validateType(FieldContext context, FieldElement field) {
    if (!field.type.isDartCoreDouble) {
      throw InvalidGenerationSourceError(
        "$name is not supported on type '${field.type.getDisplayString()}'. "
        'Supported: double',
        element: field,
      );
    }
  }

  @override
  RuleInfo parse(ConstantReader rule) {
    return RuleInfo('Finite', const {}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard!$fieldName.isFinite';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.generic]) =>
      'Value must be a finite number';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.generic]) =>
      '_Errors.finite($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'finite':
            "static ValidationError finite(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Finite',\n"
                "        message: message ?? 'Value must be a finite number',\n"
                '        path: path,\n'
                '      );',
      };
}
