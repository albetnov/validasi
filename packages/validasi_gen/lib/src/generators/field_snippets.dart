import 'package:validasi_gen/src/handlers.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

class FieldRuleSnippets {
  const FieldRuleSnippets();

  void emitInline(
    StringBuffer buf,
    FieldRules ctx, {
    String indent = '',
    required String accessor,
    required String pathExpr,
  }) {
    final hasRequired = ctx.rules.any((r) => r.name == 'Required');
    final rules = ctx.rules.where((r) => r.name != 'Nullable').toList();
    final context = ctx.context;

    if (hasRequired) {
      final rule = rules.firstWhere((r) => r.name == 'Required');
      _emitError(buf, rule, pathExpr, null, context: context, indent: indent);
    }

    for (final rule in rules) {
      if (rule.isUnknown ||
          rule.name == 'Required' ||
          rule.name == 'Nullable') {
        continue;
      }

      final gen = ruleGens[rule.name];
      if (gen == null) continue;

      final check = gen.check(rule, accessor);
      buf.writeln();
      buf.writeln('${indent}if ($check) {');
      _emitError(buf, rule, pathExpr, gen,
          context: context, indent: '$indent  ');
      buf.writeln('$indent}');
    }
  }

  void _emitError(
    StringBuffer buf,
    RuleInfo rule,
    String pathExpr,
    RuleGen? gen, {
    String context = '',
    required String indent,
  }) {
    final message = gen != null
        ? _msg(rule, gen.defaultMessage(rule, context))
        : _msg(rule, 'Field is required');
    final details = gen?.details(rule);

    buf.writeln('$indent\$errors.add(');
    buf.writeln('$indent  ValidationError(');
    buf.writeln("$indent    rule: '${rule.name}',");
    buf.writeln('$indent    message: $message,');
    if (details != null) {
      buf.writeln('$indent    details: $details,');
    }
    buf.writeln('$indent    path: $pathExpr,');
    buf.writeln('$indent  ),');
    buf.writeln('$indent);');
  }

  String _msg(RuleInfo rule, String defaultMsg) {
    if (rule.message != null && rule.message!.isNotEmpty) {
      return _escapeDartString(rule.message!);
    }
    return _escapeDartString(defaultMsg);
  }

  String _escapeDartString(String value) {
    return "'${value.replaceAll("\\", "\\\\").replaceAll("'", "\\'").replaceAll("\n", "\\n").replaceAll("\$", "\\\$")}'";
  }
}
