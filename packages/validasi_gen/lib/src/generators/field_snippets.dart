import 'package:validasi_gen/src/handlers.dart';
import 'package:validasi_gen/src/parsers/rules.dart';
import 'package:validasi_gen/src/utils.dart';

class FieldRuleSnippets {
  const FieldRuleSnippets();

  void emitInline(
    StringBuffer buf,
    FieldRules ctx, {
    String indent = '',
    required String accessor,
    required String pathExpr,
    bool async = false,
    bool requiredCheck = true,
    bool nullable = true,
  }) {
    final context = ctx.context;

    // Type-driven required check (also covers explicit @Required)
    if (requiredCheck && ctx.isRequired) {
      final rawMessage = ctx.requiredMessage ?? 'Field is required';
      final message =
          rawMessage.replaceAll('\$field', ctx.field.name ?? 'field');
      buf.writeln('$indent if ($accessor == null) {');
      buf.writeln('$indent   \$errors.add(');
      buf.writeln('$indent     ValidationError(');
      buf.writeln("$indent       rule: 'Required',");
      buf.writeln('$indent       message: ${escapeDartString(message)},');
      buf.writeln('$indent       path: $pathExpr,');
      buf.writeln('$indent     ),');
      buf.writeln('$indent   );');
      buf.writeln('$indent }');
    }

    for (final rule in ctx.rules) {
      if (rule.isUnknown ||
          rule.name == 'Required' ||
          rule.name == 'Nullable') {
        continue;
      }

      if (rule.isAsync && !async) {
        continue;
      }

      final gen = ruleGens[rule.name];
      if (gen == null) continue;

      final asyncCallExpr = gen.asyncCall(rule, accessor);
      if (asyncCallExpr != null) {
        _emitAsyncBlock(
          buf,
          rule,
          gen,
          accessor,
          pathExpr,
          asyncCallExpr,
          indent: indent,
          nullable: nullable,
        );
        continue;
      }

      final check = gen.check(rule, accessor, nullable: nullable);
      buf.writeln('$indent if ($check) {');
      _emitError(buf, rule, pathExpr, gen,
          context: context, indent: '$indent   ');
      buf.writeln('$indent }');
    }
  }

  void _emitAsyncBlock(
    StringBuffer buf,
    RuleInfo rule,
    RuleGen gen,
    String accessor,
    String pathExpr,
    String asyncCall, {
    required String indent,
    bool nullable = true,
  }) {
    final runOnNull = rule.params['runOnNull'] as bool? ?? false;
    final guard = (runOnNull || !nullable) ? '' : '$accessor != null && ';
    final errorRuleName = _errorRuleName(rule);
    final message = rule.message ?? gen.defaultMessage(rule);
    final msgLiteral = _msg(rule, message);

    buf.writeln('$indent try {');
    buf.writeln('$indent   if ($guard!await $asyncCall) {');
    buf.writeln('$indent     \$errors.add(');
    buf.writeln('$indent       ValidationError(');
    buf.writeln("$indent         rule: '$errorRuleName',");
    buf.writeln('$indent         message: $msgLiteral,');
    buf.writeln('$indent         path: $pathExpr,');
    buf.writeln('$indent       ),');
    buf.writeln('$indent     );');
    buf.writeln('$indent   }');
    buf.writeln('$indent } catch (e) {');
    buf.writeln('$indent   \$errors.add(');
    buf.writeln('$indent     ValidationError(');
    buf.writeln("$indent       rule: '$errorRuleName',");
    buf.writeln("$indent       message: e.toString(),");
    buf.writeln('$indent       path: $pathExpr,');
    buf.writeln('$indent     ),');
    buf.writeln('$indent   );');
    buf.writeln('$indent }');
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
    final errorRuleName = _errorRuleName(rule);

    buf.writeln('$indent \$errors.add(');
    buf.writeln('$indent   ValidationError(');
    buf.writeln("$indent     rule: '$errorRuleName',");
    buf.writeln('$indent     message: $message,');
    if (details != null) {
      buf.writeln('$indent     details: $details,');
    }
    buf.writeln('$indent     path: $pathExpr,');
    buf.writeln('$indent   ),');
    buf.writeln('$indent );');
  }

  static String _errorRuleName(RuleInfo rule) {
    return (rule.params['ruleName'] as String?) ??
        (rule.params['customName'] as String?) ??
        rule.name;
  }

  String _msg(RuleInfo rule, String defaultMsg) {
    if (rule.message != null && rule.message!.isNotEmpty) {
      return escapeDartString(rule.message!);
    }
    return escapeDartString(defaultMsg);
  }
}
