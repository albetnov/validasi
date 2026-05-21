import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'package:validasi_gen/src/handlers.dart';

class FieldRules {
  final FieldElement field;
  final List<RuleInfo> rules;
  FieldRules(this.field, this.rules);
}

List<FieldRules> extractValidateFields(ClassElement element) {
  final result = <FieldRules>[];

  for (final field in element.fields) {
    if (field.isSynthetic || field.isStatic) continue;

    final rules = _extractRules(field);
    if (rules != null) {
      result.add(FieldRules(field, rules));
    }
  }

  return result;
}

List<RuleInfo>? _extractRules(FieldElement field) {
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

      return rulesList.map<RuleInfo>((dartObj) {
        final ruleReader = ConstantReader(dartObj);
        return _parseRule(ruleReader);
      }).toList();
    }
  }
  return null;
}

RuleInfo _parseRule(ConstantReader rule) {
  final type = rule.objectValue.type;
  final typeElement = type?.element;
  final name = typeElement is ClassElement ? typeElement.name : 'Unknown';
  final message = rule.peek('message')?.stringValue;

  if (name == 'Required') return RuleInfo('Required', const {}, message);
  if (name == 'Nullable') return RuleInfo('Nullable', const {}, message);

  final gen = ruleGens[name];
  if (gen != null) return gen.parse(rule);

  return RuleInfo(name, const {}, message, isUnknown: true);
}
