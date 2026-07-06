import 'package:analyzer/dart/element/element.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';
import 'package:source_gen/source_gen.dart';

class EqualsGen extends RuleGen {
  @override
  String get name => 'Equals';

  @override
  RuleInfo parse(ConstantReader rule) {
    final expected = literalForConstant(rule.read('expected'));
    return RuleInfo('Equals', {'expected': expected},
        rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final expected = info.params['expected'];
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard$fieldName != $expected';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.generic]) =>
      'Value must equal ${info.params['expected']}';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.generic]) =>
      '_Errors.equals($pathExpr, ${info.params['expected']}$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'equals':
            "static ValidationError equals(List<String> path, Object? expected, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Equals',\n"
                "        message: message ?? 'Value must equal \$expected',\n"
                '        path: path,\n'
                '      );',
      };

  @override
  void validateType(FieldContext context, FieldElement field) {}
}
