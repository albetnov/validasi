import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

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
      functionName: fn?.name,
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
  String defaultMessage(RuleInfo info, [String context = '']) {
    return 'Validation failed';
  }

  @override
  String? details(RuleInfo info) => null;

  @override
  void validateType(DartType? typeArg, FieldElement field) {}
}
