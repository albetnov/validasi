import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class MoreThanGen extends RuleGen {
  @override
  String get name => 'MoreThan';

  @override
  Set<FieldContext> get supportedContexts => {FieldContext.generic};

  @override
  void validateType(FieldContext context, FieldElement field) {
    final type = field.type;
    if (!type.isDartCoreInt && !type.isDartCoreDouble) {
      throw InvalidGenerationSourceError(
        "$name is not supported on type '${type.getDisplayString()}'. "
        'Supported: int, double',
        element: field,
      );
    }
  }

  @override
  RuleInfo parse(ConstantReader rule) {
    final min = literalForConstant(rule.read('min'));
    return RuleInfo('MoreThan', {'min': min}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final min = info.params['min'];
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard$fieldName <= $min';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.generic]) =>
      'Value must be more than ${info.params['min']}';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.generic]) =>
      '_Errors.moreThan($pathExpr, ${info.params['min']}$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'moreThan':
            "static ValidationError moreThan(List<String> path, num min, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'MoreThan',\n"
                "        message: message ?? 'Value must be more than \$min',\n"
                '        path: path,\n'
                '      );',
      };
}
