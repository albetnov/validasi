import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class MaxLengthGen extends RuleGen {
  @override
  String get name => 'MaxLength';

  @override
  RuleInfo parse(ConstantReader rule) {
    final length = rule.read('length').intValue;
    return RuleInfo(
      'MaxLength',
      {'length': length},
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
    if (typeArg is InterfaceType) {
      final name = typeArg.element.name;
      if (name == 'Iterable' || name == 'List' || name == 'Set') return;
    }
    throw InvalidGenerationSourceError(
      "MaxLength does not support type '${typeArg.getDisplayString()}'. "
      "Supported: String, Iterable<T>",
      element: field,
    );
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final length = info.params['length'] as int;
    final guard = nullable ? '$fieldName != null && ' : '';
    return '$guard$fieldName.length > $length';
  }

  @override
  String defaultMessage(RuleInfo info, [String context = '']) {
    final length = info.params['length'];
    if (context == 'iterable') {
      return 'List must have at most $length items';
    }
    return 'Maximum length is $length characters';
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [String context = '']) {
    final length = info.params['length'] as int;
    if (context == 'iterable') {
      return '_Errors.itMaxLength($pathExpr, $length$messageArg)';
    }
    return '_Errors.maxLength($pathExpr, $length$messageArg)';
  }

  @override
  Map<String, String> get helperMethods => {
        'maxLength':
            "static ValidationError maxLength(List<String> path, int length, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'MaxLength',\n"
                "        message: message ?? 'Maximum length is \$length characters',\n"
                "        details: {'length': '\$length'},\n"
                '        path: path,\n'
                '      );',
        'itMaxLength':
            "static ValidationError itMaxLength(List<String> path, int length, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'MaxLength',\n"
                "        message: message ?? 'List must have at most \$length items',\n"
                "        details: {'length': '\$length'},\n"
                '        path: path,\n'
                '      );',
      };
}
