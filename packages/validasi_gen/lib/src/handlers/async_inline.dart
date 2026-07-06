import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class AsyncInlineGen extends RuleGen {
  @override
  String get name => 'AsyncInline';

  @override
  bool get isAsync => true;

  @override
  RuleInfo parse(ConstantReader rule) {
    final fn = rule.read('validator').objectValue.toFunctionValue();
    final customName = rule.peek('name')?.stringValue ?? 'async_inline';
    return RuleInfo(
      'AsyncInline',
      {
        'customName': customName,
        'runOnNull': true,
      },
      rule.peek('message')?.stringValue,
      isAsync: true,
      functionName: qualifiedFunctionName(fn),
    );
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    return 'false';
  }

  @override
  String? asyncCall(RuleInfo info, String fieldName) {
    final fn = info.functionName ?? '_unknown';
    return '$fn($fieldName)';
  }

  @override
  String defaultMessage(RuleInfo info,
      [FieldContext context = FieldContext.string]) {
    return 'Validation failed';
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.string]) {
    final ruleName = _errorRuleName(info);
    final message = info.message != null
        ? escapeDartString(info.message!)
        : escapeDartString(defaultMessage(info, context));
    return "_Errors.inline($pathExpr, '$ruleName', $message)";
  }

  @override
  Map<String, String> get helperMethods => {
        'inline':
            "static ValidationError inline(List<String> path, String rule, String message) =>\n"
                '      ValidationError(rule: rule, message: message, path: path);',
      };

  @override
  void validateType(FieldContext context, FieldElement field) {}

  static String _errorRuleName(RuleInfo rule) {
    return (rule.params['ruleName'] as String?) ??
        (rule.params['customName'] as String?) ??
        rule.name;
  }
}
