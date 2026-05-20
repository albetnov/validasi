import 'dart:async';

import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:validasi/validasi.dart';

class ValidasiGenerator extends GeneratorForAnnotation<Validasi> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) return '';

    final fields = <_FieldContext>[];

    for (final field in element.fields) {
      if (field.isSynthetic || field.isStatic) continue;

      final rules = _extractRules(field);
      if (rules != null) {
        fields.add(_FieldContext(field, rules));
      }
    }

    if (fields.isEmpty) return '';

    return _generateExtension(element.name, fields);
  }

  List<_RuleInfo>? _extractRules(FieldElement field) {
    for (final meta in field.metadata) {
      final element = meta.element;
      if (element is ConstructorElement &&
          element.enclosingElement.name == 'Validate') {
        final constant = meta.computeConstantValue();
        if (constant == null) return null;

        final reader = ConstantReader(constant);
        final rulesReader = reader.read('rules');
        final rulesList = rulesReader.listValue;
        if (rulesList.isEmpty) return [];

        return rulesList.map<_RuleInfo>((dartObj) {
          final ruleReader = ConstantReader(dartObj);
          return _parseRule(ruleReader);
        }).toList();
      }
    }
    return null;
  }

  _RuleInfo _parseRule(ConstantReader rule) {
    final type = rule.objectValue.type;
    final typeElement = type?.element;
    final name = typeElement is ClassElement ? typeElement.name : 'Unknown';
    final message = rule.peek('message')?.stringValue;

    switch (name) {
      case 'Required':
        return _RuleInfo('Required', const {}, message);
      case 'Nullable':
        return _RuleInfo('Nullable', const {}, message);
      case 'MinLength':
        final length = rule.read('length').intValue;
        return _RuleInfo('MinLength', {'length': length}, message);
      case 'MaxLength':
        final length = rule.read('length').intValue;
        return _RuleInfo('MaxLength', {'length': length}, message);
      case 'OneOf':
        final optionsReader = rule.read('options');
        final optionsList = optionsReader.listValue;
        final options = <String>[];
        for (final o in optionsList) {
          final val = ConstantReader(o).stringValue;
          options.add(val);
        }
        return _RuleInfo('OneOf', {'options': options}, message);
      default:
        return _RuleInfo(name, const {}, message, isUnknown: true);
    }
  }

  String _generateExtension(String className, List<_FieldContext> fields) {
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
    buf.writeln(
        "      return ValidasiResult(errors: \$errors, isValid: false);");
    buf.writeln('    }');
    buf.writeln(
        '    return ValidasiResult(errors: [], isValid: true, data: this);');
    buf.writeln('  }');
    buf.writeln('}');

    return buf.toString();
  }

  void _generateFieldValidation(StringBuffer buf, _FieldContext ctx) {
    final fieldName = ctx.field.name;
    final hasRequired = ctx.rules.any((r) => r.name == 'Required');
    final rules = ctx.rules.where((r) => r.name != 'Nullable').toList();

    buf.writeln('    // Field: $fieldName');

    if (hasRequired) {
      buf.writeln('    if ($fieldName == null) {');
      buf.writeln("      \$errors.add(");
      buf.writeln('        ValidationError(');
      buf.writeln("          rule: 'Required',");
      buf.writeln(
          "          message: ${_msg(rules.firstWhere((r) => r.name == 'Required'), 'Field is required')},");
      buf.writeln("          path: ['$fieldName'],");
      buf.writeln('        ),');
      buf.writeln('      );');
      buf.writeln('    }');
    }

    for (final rule in rules) {
      if (rule.isUnknown || rule.name == 'Required' || rule.name == 'Nullable')
        continue;

      final check = _generatedCheck(rule, fieldName);
      if (check == null) continue;

      buf.writeln();
      buf.writeln('    if ($check) {');
      buf.writeln("      \$errors.add(");
      buf.writeln('        ValidationError(');
      buf.writeln("          rule: '${rule.name}',");
      buf.writeln("          message: ${_msg(rule, _defaultMessage(rule))},");

      final details = _detailsMap(rule);
      if (details != null) {
        buf.writeln('          details: $details,');
      }

      buf.writeln("          path: ['$fieldName'],");
      buf.writeln('        ),');
      buf.writeln('      );');
      buf.writeln('    }');
    }

    buf.writeln();
  }

  String? _generatedCheck(_RuleInfo rule, String fieldName) {
    switch (rule.name) {
      case 'MinLength':
        final length = rule.params['length'] as int;
        return '$fieldName != null && $fieldName.length < $length';
      case 'MaxLength':
        final length = rule.params['length'] as int;
        return '$fieldName != null && $fieldName.length > $length';
      case 'OneOf':
        final options = rule.params['options'] as List<String>;
        final items = options.map((o) => _escapeDartString(o)).join(', ');
        return '$fieldName != null && ![$items].contains($fieldName)';
      default:
        return null;
    }
  }

  String _defaultMessage(_RuleInfo rule) {
    switch (rule.name) {
      case 'Required':
        return 'Field is required';
      case 'MinLength':
        return 'Minimum length is ${rule.params['length']} characters';
      case 'MaxLength':
        return 'Maximum length is ${rule.params['length']} characters';
      case 'OneOf':
        return 'Value must be one of: ${(rule.params['options'] as List<String>).join(', ')}';
      default:
        return 'Validation failed';
    }
  }

  String? _detailsMap(_RuleInfo rule) {
    switch (rule.name) {
      case 'MinLength':
        return "{'length': '${rule.params['length']}'}";
      case 'MaxLength':
        return "{'length': '${rule.params['length']}'}";
      default:
        return null;
    }
  }

  String _msg(_RuleInfo rule, String defaultMsg) {
    if (rule.message != null && rule.message!.isNotEmpty) {
      return _escapeDartString(rule.message!);
    }
    return _escapeDartString(defaultMsg);
  }

  String _escapeDartString(String value) {
    return "'${value.replaceAll("\\", "\\\\").replaceAll("'", "\\'").replaceAll("\n", "\\n").replaceAll("\$", "\\\$")}'";
  }
}

class _FieldContext {
  final FieldElement field;
  final List<_RuleInfo> rules;
  _FieldContext(this.field, this.rules);
}

class _RuleInfo {
  final String name;
  final Map<String, Object?> params;
  final String? message;
  final bool isUnknown;
  _RuleInfo(this.name, this.params, this.message, {this.isUnknown = false});
}
