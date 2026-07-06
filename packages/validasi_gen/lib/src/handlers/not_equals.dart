import 'package:analyzer/dart/element/element.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';
import 'package:source_gen/source_gen.dart';

class NotEqualsGen extends RuleGen {
  @override
  String get name => 'NotEquals';

  @override
  RuleInfo parse(ConstantReader rule) {
    final unexpected = literalForConstant(rule.read('unexpected'));
    return RuleInfo('NotEquals', {'unexpected': unexpected},
        rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final unexpected = info.params['unexpected'];
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard$fieldName == $unexpected';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.generic]) =>
      'Value must not equal ${info.params['unexpected']}';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.generic]) =>
      '_Errors.notEquals($pathExpr, ${info.params['unexpected']}$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'notEquals':
            "static ValidationError notEquals(List<String> path, Object? unexpected, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'NotEquals',\n"
                "        message: message ?? 'Value must not equal \$unexpected',\n"
                '        path: path,\n'
                '      );',
      };

  @override
  void validateType(FieldContext context, FieldElement field) {}
}
