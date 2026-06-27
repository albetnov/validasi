import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class OneOfGen extends RuleGen {
  @override
  String get name => 'OneOf';

  @override
  RuleInfo parse(ConstantReader rule) {
    final optionsList = rule.read('options').listValue;
    final options = <String>[];
    for (final o in optionsList) {
      options.add(ConstantReader(o).stringValue);
    }
    return RuleInfo(
      'OneOf',
      {'options': options},
      rule.peek('message')?.stringValue,
      typeArg: typeArgOf(rule),
    );
  }

  @override
  void validateType(DartType? typeArg, FieldElement field) {
    if (typeArg == null || typeArg is DynamicType || typeArg.isDartCoreObject) {
      return;
    }
    if (typeArg.isDartCoreString) return;
    throw InvalidGenerationSourceError(
      "OneOf does not support type '${typeArg.getDisplayString()}'. "
      "Supported: String",
      element: field,
    );
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final options = info.params['options'] as List<String>;
    final items = options.map(escapeDartString).join(', ');
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard![$items].contains($fieldName)';
  }

  @override
  String defaultMessage(RuleInfo info, [String context = '']) {
    final options = (info.params['options'] as List<String>).join(', ');
    return 'Value must be one of: $options';
  }

  @override
  String? details(RuleInfo info) => null;
}
