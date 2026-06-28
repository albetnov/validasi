import 'package:validasi_gen/src/handlers.dart';
import 'package:validasi_gen/src/handlers/required.dart';
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
          rawMessage.replaceAll(r'$field', ctx.field.name ?? 'field');
      final messageArg = ctx.requiredMessage != null
          ? ', message: ${escapeDartString(message)}'
          : '';
      final rdIndent = indent.isEmpty ? '  ' : '$indent    ';
      buf.writeln('$indent if ($accessor == null) {');
      buf.writeln(
          '$rdIndent \$errors.add(${const RequiredHelper().emitError(pathExpr, messageArg)});');
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
      final messageArg = rule.message != null
          ? ', message: ${escapeDartString(rule.message!)}'
          : '';
      final errorCall = gen.emitError(rule, pathExpr, messageArg, context);
      buf.writeln('$indent if ($check) {');
      buf.writeln('$indent   \$errors.add($errorCall);');
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
    final messageArg = rule.message != null
        ? ', message: ${escapeDartString(rule.message!)}'
        : '';
    final errorCall = gen.emitError(rule, pathExpr, messageArg);

    buf.writeln('$indent try {');
    buf.writeln('$indent   if ($guard!await $asyncCall) {');
    buf.writeln('$indent     \$errors.add($errorCall);');
    buf.writeln('$indent   }');
    buf.writeln('$indent } catch (e) {');
    buf.writeln(
        '$indent   \$errors.add(_Errors.inline($pathExpr, \'${_errorRuleName(rule)}\', e.toString()));');
    buf.writeln('$indent }');
  }

  static String _errorRuleName(RuleInfo rule) {
    return (rule.params['ruleName'] as String?) ??
        (rule.params['customName'] as String?) ??
        rule.name;
  }
}
