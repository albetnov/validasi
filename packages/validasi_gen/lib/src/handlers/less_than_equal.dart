import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class LessThanEqualGen extends RuleGen {
  @override
  String get name => 'LessThanEqual';

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
    final max = literalForConstant(rule.read('max'));
    return RuleInfo(
        'LessThanEqual', {'max': max}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final max = info.params['max'];
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard$fieldName > $max';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.generic]) =>
      'Value must be less than or equal to ${info.params['max']}';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.generic]) =>
      '_Errors.lessThanEqual($pathExpr, ${info.params['max']}$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'lessThanEqual':
            "static ValidationError lessThanEqual(List<String> path, num max, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'LessThanEqual',\n"
                "        message: message ?? 'Value must be less than or equal to \$max',\n"
                '        path: path,\n'
                '      );',
      };
}
