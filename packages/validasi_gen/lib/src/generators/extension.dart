import 'package:validasi_gen/src/handlers.dart';
import 'package:validasi_gen/src/parsers/rules.dart';

String generateValidateExtension(String className, List<FieldRules> fields) {
  final buf = StringBuffer();

  buf.writeln();
  buf.writeln('extension \$${className}Validasi on $className {');
  buf.writeln('  ValidasiResult<$className> validate() {');
  buf.writeln("    final \$errors = <ValidationError>[];");
  buf.writeln();

  for (final ctx in fields) {
    _generateFieldValidation(buf, ctx);
  }

  buf.writeln("    if (\$errors.isNotEmpty) {");
  buf.writeln("      return ValidasiResult(errors: \$errors, isValid: false);");
  buf.writeln('    }');
  buf.writeln('    return ValidasiResult(errors: [], isValid: true, data: this);');
  buf.writeln('  }');
  buf.writeln('}');

  return buf.toString();
}

void _generateFieldValidation(StringBuffer buf, FieldRules ctx) {
  final fieldName = ctx.field.name;
  final hasRequired = ctx.rules.any((r) => r.name == 'Required');
  final rules = ctx.rules.where((r) => r.name != 'Nullable').toList();

  buf.writeln('    // Field: $fieldName');

  if (hasRequired) {
    final rule = rules.firstWhere((r) => r.name == 'Required');
    _emitError(buf, rule, fieldName);
  }

  for (final rule in rules) {
    if (rule.isUnknown ||
        rule.name == 'Required' ||
        rule.name == 'Nullable') {
      continue;
    }

    final gen = ruleGens[rule.name];
    if (gen == null) continue;

    final check = gen.check(rule, fieldName);
    buf.writeln();
    buf.writeln('    if ($check) {');
    _emitError(buf, rule, fieldName, gen);
    buf.writeln('    }');
  }

  buf.writeln();
}

void _emitError(StringBuffer buf, RuleInfo rule, String fieldName,
    [RuleGen? gen]) {
  final message = gen != null
      ? _msg(rule, gen.defaultMessage(rule))
      : _msg(rule, 'Field is required');
  final details = gen?.details(rule);

  buf.writeln("      \$errors.add(");
  buf.writeln('        ValidationError(');
  buf.writeln("          rule: '${rule.name}',");
  buf.writeln("          message: $message,");
  if (details != null) {
    buf.writeln('          details: $details,');
  }
  buf.writeln("          path: ['$fieldName'],");
  buf.writeln('        ),');
  buf.writeln('      );');
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
