import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class InlineGen extends RuleGen {
  @override
  String get name => 'Inline';

  @override
  RuleInfo parse(ConstantReader rule) {
    final fn = rule.read('validator').objectValue.toFunctionValue();
    final customName = rule.peek('name')?.stringValue ?? 'inline';
    final message = rule.peek('message')?.stringValue;
    final runOnNull = rule.peek('runOnNull')?.boolValue ?? false;
    final typeArg = typeArgOf(rule);

    return RuleInfo(
      'Inline',
      {
        'customName': customName,
        'runOnNull': runOnNull,
      },
      message,
      typeArg: typeArg,
      functionName: fn?.name,
    );
  }

  @override
  String check(RuleInfo info, String fieldName) {
    final fn = info.functionName ?? '_unknown';
    final runOnNull = info.params['runOnNull'] as bool? ?? false;

    if (runOnNull) {
      return '!$fn($fieldName)';
    }
    return '$fieldName != null && !$fn($fieldName)';
  }

  @override
  String defaultMessage(RuleInfo info, [String context = '']) {
    final customName = info.params['customName'] as String? ?? 'inline';
    return '$customName: validation failed.';
  }

  @override
  String? details(RuleInfo info) => null;

  @override
  void validateType(DartType? typeArg, FieldElement field) {}
}
