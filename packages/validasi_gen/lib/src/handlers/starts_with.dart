import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

class StartsWithGen extends RuleGen {
  @override
  String get name => 'StartsWith';

  @override
  Set<FieldContext> get supportedContexts => {FieldContext.string};

  @override
  void validateType(FieldContext context, FieldElement field) {
    if (!supportedContexts.contains(context)) {
      throw InvalidGenerationSourceError(
        "$name is not supported on type '${field.type.getDisplayString()}'. "
        'Supported: ${supportedContexts.map((c) => c.name)}',
        element: field,
      );
    }
  }

  @override
  RuleInfo parse(ConstantReader rule) {
    final prefix = rule.read('prefix').stringValue;
    return RuleInfo(
        'StartsWith', {'prefix': prefix}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final prefix = info.params['prefix'] as String;
    final guard = nullable ? '$fieldName != null && ' : '';
    final expr = nullable ? '$fieldName!' : fieldName;
    return '$guard!$expr.startsWith(${escapeDartString(prefix)})';
  }

  @override
  String defaultMessage(RuleInfo info,
      [FieldContext context = FieldContext.string]) {
    final prefix = info.params['prefix'] as String;
    return 'Must start with "$prefix"';
  }

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.string]) {
    final prefix = info.params['prefix'] as String;
    return '_Errors.startsWith($pathExpr, ${escapeDartString(prefix)}$messageArg)';
  }

  @override
  Map<String, String> get helperMethods => {
        'startsWith':
            "static ValidationError startsWith(List<String> path, String prefix, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'StartsWith',\n"
                "        message: message ?? 'Must start with \"\$prefix\"',\n"
                "        details: {'prefix': prefix},\n"
                '        path: path,\n'
                '      );',
      };
}
