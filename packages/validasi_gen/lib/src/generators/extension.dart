import 'package:analyzer/dart/element/nullability_suffix.dart';
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
  if (ctx.isNested) {
    _generateNestedValidation(buf, ctx);
    return;
  }

  final fieldName = ctx.field.name;
  final hasRequired = ctx.rules.any((r) => r.name == 'Required');
  final rules = ctx.rules.where((r) => r.name != 'Nullable').toList();
  final context = ctx.context;

  buf.writeln('    // Field: $fieldName');

  if (hasRequired) {
    final rule = rules.firstWhere((r) => r.name == 'Required');
    _emitError(buf, rule, fieldName, null, context);
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
    _emitError(buf, rule, fieldName, gen, context);
    buf.writeln('    }');
  }

  buf.writeln();
}

void _generateNestedValidation(StringBuffer buf, FieldRules ctx) {
  final fieldName = ctx.field.name;
  final nestedClassName = ctx.nestedClassName!;
  final isIterable = ctx.isNestedIterable;
  final isNullable = ctx.field.type.nullabilitySuffix != NullabilitySuffix.none;

  buf.writeln('    // Field: $fieldName (nested $nestedClassName)');

  if (isIterable) {
    _generateNestedIterableValidation(buf, fieldName, nestedClassName, isNullable);
  } else {
    _generateNestedObjectValidation(buf, fieldName, nestedClassName, isNullable);
  }

  buf.writeln();
}

void _generateNestedObjectValidation(
    StringBuffer buf, String fieldName, String nestedClassName, bool isNullable) {
  final resultVar = '\$${fieldName}Result';

  if (isNullable) {
    final localVar = '\$${fieldName}Value';
    buf.writeln('    final $localVar = $fieldName;');
    buf.writeln('    if ($localVar != null) {');
    buf.writeln('      final $resultVar = $localVar.validate();');
    buf.writeln('      if (!$resultVar.isValid) {');
    buf.writeln('        \$errors.addAll($resultVar.errors.map((e) => e.withPrefix(\'$fieldName\')));');
    buf.writeln('      }');
    buf.writeln('    }');
  } else {
    buf.writeln('    final $resultVar = $fieldName.validate();');
    buf.writeln('    if (!$resultVar.isValid) {');
    buf.writeln('      \$errors.addAll($resultVar.errors.map((e) => e.withPrefix(\'$fieldName\')));');
    buf.writeln('    }');
  }
}

void _generateNestedIterableValidation(
    StringBuffer buf, String fieldName, String nestedClassName, bool isNullable) {
  final indexVar = '\$${fieldName}Index';
  final itemVar = '\$${fieldName}Item';
  final resultVar = '\$${fieldName}ItemResult';

  void generateBody(String indent, String collectionName) {
    buf.writeln('${indent}for (var $indexVar = 0; $indexVar < $collectionName.length; $indexVar++) {');
    buf.writeln('${indent}  final $itemVar = $collectionName[$indexVar];');
    buf.writeln('${indent}  final $resultVar = $itemVar.validate();');
    buf.writeln('${indent}  if (!$resultVar.isValid) {');
    buf.writeln('${indent}    \$errors.addAll($resultVar.errors.map((e) => e.withPrefix(\'$fieldName[\${$indexVar}]\')));');
    buf.writeln('${indent}  }');
    buf.writeln('${indent}}');
  }

  if (isNullable) {
    final localVar = '\$${fieldName}Value';
    buf.writeln('    final $localVar = $fieldName;');
    buf.writeln('    if ($localVar != null) {');
    generateBody('      ', localVar);
    buf.writeln('    }');
  } else {
    generateBody('    ', fieldName);
  }
}

void _emitError(StringBuffer buf, RuleInfo rule, String fieldName,
    [RuleGen? gen, String context = '']) {
  final message = gen != null
      ? _msg(rule, gen.defaultMessage(rule, context))
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
