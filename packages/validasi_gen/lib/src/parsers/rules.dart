import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import 'package:validasi_gen/src/handlers.dart';

class FieldRules {
  final FieldElement field;
  final List<RuleInfo> rules;
  final String context;
  final String? nestedClassName;
  final bool isNestedIterable;

  FieldRules(
    this.field,
    this.rules, {
    this.context = '',
    this.nestedClassName,
    this.isNestedIterable = false,
  });

  bool get isNested => nestedClassName != null;
}

List<FieldRules> extractValidateFields(
    ClassElement element, LibraryReader library) {
  final result = <FieldRules>[];

  for (final field in element.fields) {
    if (field.isSynthetic || field.isStatic) continue;

    final extracted = _extractRules(field);
    if (extracted != null) {
      result.add(FieldRules(field, extracted.$1, context: extracted.$2));
      continue;
    }

    final nested = _detectNestedField(field, library);
    if (nested != null) {
      result.add(FieldRules(
        field,
        const [],
        nestedClassName: nested.$1,
        isNestedIterable: nested.$2,
      ));
    }
  }

  return result;
}

bool _hasValidateClassAnnotation(ClassElement cls) {
  return cls.metadata.any((meta) {
    final element = meta.element;
    return element is ConstructorElement &&
        element.enclosingElement.name == 'ValidateClass';
  });
}

(String className, bool isIterable)? _detectNestedField(
    FieldElement field, LibraryReader library) {
  final type = field.type;

  if (type.isDartCoreMap) return null;

  if (type is InterfaceType) {
    final typeName = type.element.name;
    if (typeName == 'List' || typeName == 'Iterable' || typeName == 'Set') {
      if (type.typeArguments.isNotEmpty) {
        final elementType = type.typeArguments.first;
        final elementClass = _getClassFromType(elementType);
        if (elementClass != null && _hasValidateClassAnnotation(elementClass)) {
          return (elementClass.name, true);
        }
      }
    }
  }

  final directClass = _getClassFromType(type);
  if (directClass != null && _hasValidateClassAnnotation(directClass)) {
    return (directClass.name, false);
  }

  return null;
}

ClassElement? _getClassFromType(DartType type) {
  final element = type.element;
  if (element is ClassElement) return element;
  return null;
}

(List<RuleInfo>, String)? _extractRules(FieldElement field) {
  for (final meta in field.metadata) {
    final element = meta.element;
    if (element is ConstructorElement &&
        element.enclosingElement.name == 'Validate') {
      final context = element.name;
      final constant = meta.computeConstantValue();
      if (constant == null) return null;

      final reader = ConstantReader(constant);
      final rulesReader = reader.read('rules');
      final rulesList = rulesReader.listValue;
      if (rulesList.isEmpty) return ([], context);

      final rules = rulesList.map<RuleInfo>((dartObj) {
        final ruleReader = ConstantReader(dartObj);
        final rule = _parseRule(ruleReader);
        final gen = ruleGens[rule.name];
        if (gen != null) gen.validateType(rule.typeArg, field);
        return rule;
      }).toList();
      return (rules, context);
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
