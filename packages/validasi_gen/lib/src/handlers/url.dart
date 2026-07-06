import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class UrlGen extends RuleGen {
  @override
  String get name => 'Url';

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
    final requireScheme = rule.peek('requireScheme')?.boolValue ?? true;
    final requireHost = rule.peek('requireHost')?.boolValue ?? true;
    final httpsOnly = rule.peek('httpsOnly')?.boolValue ?? false;
    return RuleInfo(
      'Url',
      {
        'requireScheme': requireScheme,
        'requireHost': requireHost,
        'httpsOnly': httpsOnly,
      },
      rule.peek('message')?.stringValue,
    );
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final requireScheme = info.params['requireScheme'] as bool;
    final requireHost = info.params['requireHost'] as bool;
    final httpsOnly = info.params['httpsOnly'] as bool;
    final guard = nullable ? '$fieldName != null && ' : '';

    return '$guard(() {\n'
        '    final uri = Uri.tryParse($fieldName);\n'
        '    if (uri == null) return true;\n'
        '${requireScheme ? "    if (uri.scheme.isEmpty) return true;\n" : ""}'
        '${httpsOnly ? "    if (uri.scheme != 'https') return true;\n" : ""}'
        '${requireHost ? "    if (uri.host.isEmpty) return true;\n" : ""}'
        '    return false;\n'
        '  })()';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.string]) =>
      'Must be a valid URL';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.string]) =>
      '_Errors.url($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'url':
            "static ValidationError url(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Url',\n"
                "        message: message ?? 'Must be a valid URL',\n"
                '        path: path,\n'
                '      );',
      };
}
