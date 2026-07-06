import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';
import 'package:validasi_gen/src/utils.dart';

const _localPartPattern = r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+$";
const _localPartIntlPattern = r"^[\p{L}\p{N}!#$%&'*+/=?^_`{|}~.-]+$";
const _domainPattern =
    r'^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*$';
const _domainIntlPattern =
    r'^[\p{L}\p{N}]([\p{L}\p{N}-]*[\p{L}\p{N}])?(\.[\p{L}\p{N}]([\p{L}\p{N}-]*[\p{L}\p{N}])?)*$';

class EmailGen extends RuleGen {
  @override
  String get name => 'Email';

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
    final allowTopLevelDomain =
        rule.peek('allowTopLevelDomain')?.boolValue ?? false;
    final allowInternational =
        rule.peek('allowInternational')?.boolValue ?? false;
    final domains = rule
        .peek('domains')
        ?.listValue
        .map((d) => ConstantReader(d).stringValue)
        .toList();
    return RuleInfo(
      'Email',
      {
        'allowTopLevelDomain': allowTopLevelDomain,
        'allowInternational': allowInternational,
        'domains': domains,
      },
      rule.peek('message')?.stringValue,
    );
  }

  @override
  String check(RuleInfo info, String fieldName, {bool nullable = true}) {
    final guard = nullable ? '$fieldName != null && ' : '';
    final allowIntl = info.params['allowInternational'] as bool;
    final allowTld = info.params['allowTopLevelDomain'] as bool;
    final domains = info.params['domains'] as List<String>?;

    final localPattern = allowIntl ? _localPartIntlPattern : _localPartPattern;
    final domainPattern = allowIntl ? _domainIntlPattern : _domainPattern;
    final unicodeFlag = allowIntl ? ', unicode: true' : '';
    final localPatternLit = escapeDartString(localPattern);
    final domainPatternLit = escapeDartString(domainPattern);

    final domainsCheck = (domains == null || domains.isEmpty)
        ? ''
        : '    if (!${'[${domains.map(escapeDartString).join(', ')}]'}.contains(domain.toLowerCase())) return true;\n';

    final body = '(() {\n'
        '    final v = $fieldName;\n'
        "    final at = v.lastIndexOf('@');\n"
        '    if (at <= 0 || at == v.length - 1) return true;\n'
        '    final local = v.substring(0, at);\n'
        '    final domain = v.substring(at + 1);\n'
        '    if (local.isEmpty || local.length > 64) return true;\n'
        "    if (local.startsWith('.') || local.endsWith('.')) return true;\n"
        "    if (local.contains('..')) return true;\n"
        '    if (!RegExp($localPatternLit$unicodeFlag).hasMatch(local)) return true;\n'
        '    if (domain.isEmpty || domain.length > 255) return true;\n'
        '    if (!RegExp($domainPatternLit$unicodeFlag).hasMatch(domain)) return true;\n'
        "    final labels = domain.split('.');\n"
        '    if (!$allowTld && labels.length < 2) return true;\n'
        '    for (final label in labels) {\n'
        '      if (label.isEmpty || label.length > 63) return true;\n'
        '    }\n'
        '    final tld = labels.last;\n'
        "    if (!$allowTld && (tld.length < 2 || RegExp(r'^[0-9]+\$').hasMatch(tld))) return true;\n"
        '$domainsCheck'
        '    return false;\n'
        '  })()';

    return '$guard$body';
  }

  @override
  String defaultMessage(RuleInfo info,
          [FieldContext context = FieldContext.string]) =>
      'Must be a valid email address';

  @override
  String emitError(RuleInfo info, String pathExpr, String messageArg,
          [FieldContext context = FieldContext.string]) =>
      '_Errors.email($pathExpr$messageArg)';

  @override
  Map<String, String> get helperMethods => {
        'email':
            "static ValidationError email(List<String> path, {String? message}) =>\n"
                '      ValidationError(\n'
                "        rule: 'Email',\n"
                "        message: message ?? 'Must be a valid email address',\n"
                '        path: path,\n'
                '      );',
      };
}
