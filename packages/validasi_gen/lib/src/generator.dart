import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'package:validasi_gen/src/generators/cross_field_sugar.dart';
import 'package:validasi_gen/src/generators/cross_fields.dart';
import 'package:validasi_gen/src/generators/error_helpers.dart';
import 'package:validasi_gen/src/generators/extension.dart';
import 'package:validasi_gen/src/generators/fields_class.dart';
import 'package:validasi_gen/src/generators/form_validator.dart';
import 'package:validasi_gen/src/handlers.dart';
import 'package:validasi_gen/src/handlers/required.dart';
import 'package:validasi_gen/src/parsers/cross_field_rules.dart';
import 'package:validasi_gen/src/parsers/rules.dart';
import 'package:validasi_gen/src/utils.dart';

class ValidasiGenerator extends Generator {
  ValidasiGenerator({
    this.generateFieldsDefault = true,
    this.generateSchemaDefault = true,
    this.generateValidateFormDefault = false,
    this.generateIndexedFieldsDefault = false,
  });

  final bool generateFieldsDefault;
  final bool generateSchemaDefault;
  final bool generateValidateFormDefault;
  final bool generateIndexedFieldsDefault;

  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final validateClasses = <String, ClassElement>{};
    for (final cls in library.classes) {
      if (hasValidateClassAnnotation(cls)) {
        validateClasses[cls.name!] = cls;
      }
    }

    _detectCycles(validateClasses, library);

    final buffer = StringBuffer();

    for (final cls in validateClasses.values) {
      final fields = extractValidateFields(cls, library);
      final refines = extractRefineMethods(cls);
      final crossFieldInfos = extractCrossFieldRules(cls);
      if (fields.isEmpty && refines.isEmpty && crossFieldInfos.isEmpty) {
        continue;
      }

      final generateFields =
          readGenerateFieldsOverride(cls) ?? generateFieldsDefault;
      final generateSchema =
          readGenerateSchemaOverride(cls) ?? generateSchemaDefault;
      final generateIndexedFields = readGenerateIndexedFieldsOverride(cls) ??
          generateIndexedFieldsDefault;
      final desugaredCrossField =
          desugarCrossFieldRules(cls.name!, cls, crossFieldInfos);
      final allRefines = [
        ...refines,
        ...desugaredCrossField.map((d) => d.refine),
      ];
      final shouldEmitValidateForm =
          generateFields && generateValidateFormDefault;

      if (generateFields) {
        buffer.write(generateFieldsClass(
          cls.name!,
          fields,
          generateIndexedFields: generateIndexedFields,
          generateSchema: generateSchema,
        ));
        if (generateSchema) {
          buffer.write(generateSchemaClass(
            cls.name!,
            fields,
            implementFormValidator: shouldEmitValidateForm,
          ));
        }
      }

      buffer.write(generateValidateExtension(
        cls.name!,
        fields,
        includeValidateField: generateFields,
        refines: allRefines,
        allFieldNames:
            cls.fields.where((f) => !f.isStatic).map((f) => f.name!).toList(),
      ));

      if (shouldEmitValidateForm) {
        buffer.write(
            generateValidateForm(cls.name!, fields, refines: allRefines));
      }

      if (desugaredCrossField.isNotEmpty) {
        buffer.write(
            generateCrossFieldHelperClass(cls.name!, desugaredCrossField));
      }
    }

    if (validateClasses.isNotEmpty) {
      final source = buffer.toString();
      final usedHelpers = _scanUsedHelpers(source);
      if (usedHelpers.isNotEmpty) {
        buffer.writeln();
        buffer.write(_generateErrorHelpers(usedHelpers));
      }
      buffer.writeln();
      buffer.write(generateResultHelper());
    }

    return buffer.toString();
  }

  void _detectCycles(
      Map<String, ClassElement> validateClasses, LibraryReader library) {
    final graph = <String, Set<String>>{};

    for (final entry in validateClasses.entries) {
      final className = entry.key;
      final cls = entry.value;
      final deps = <String>{};

      for (final field in cls.fields) {
        if (field.isStatic) continue;
        final nested = detectNestedField(field, library);
        if (nested != null && validateClasses.containsKey(nested.$1)) {
          deps.add(nested.$1);
        }
      }

      graph[className] = deps;
    }

    final visited = <String>{};
    final inStack = <String>{};
    final path = <String>[];

    for (final className in graph.keys) {
      if (_dfsCycle(className, graph, visited, inStack, path)) {
        final duplicateNode = path.last;
        final cycleStart = path.indexOf(duplicateNode);
        final cycle = path.sublist(cycleStart);

        throw InvalidGenerationSourceError(
          'Circular dependency detected in @ValidateClass() types: ${cycle.join(' -> ')}',
        );
      }
    }
  }

  bool _dfsCycle(
    String node,
    Map<String, Set<String>> graph,
    Set<String> visited,
    Set<String> inStack,
    List<String> path,
  ) {
    if (inStack.contains(node)) {
      path.add(node);
      return true;
    }

    if (visited.contains(node)) {
      return false;
    }

    visited.add(node);
    inStack.add(node);
    path.add(node);

    final deps = graph[node] ?? {};
    for (final dep in deps) {
      if (_dfsCycle(dep, graph, visited, inStack, path)) {
        return true;
      }
    }

    inStack.remove(node);
    path.removeLast();
    return false;
  }

  /// Builds a registry of all helper method names to their source code.
  static Map<String, String> get _helperRegistry {
    final registry = <String, String>{};
    for (final gen in ruleGens.values) {
      registry.addAll(gen.helperMethods);
    }
    registry.addAll(RequiredHelper.helperMethods);
    return registry;
  }

  /// Scans the generated source for `_Errors.<name>(` patterns and returns
  /// the set of used helper names.
  static Set<String> _scanUsedHelpers(String source) {
    final registry = _helperRegistry;
    final used = <String>{};
    final pattern = RegExp(r'_Errors\.(\w+)\(');
    for (final match in pattern.allMatches(source)) {
      final name = match.group(1)!;
      if (registry.containsKey(name)) {
        used.add(name);
      }
    }
    return used;
  }

  /// Generates the `_Errors` class with only the used helper methods.
  static String _generateErrorHelpers(Set<String> usedNames) {
    final registry = _helperRegistry;
    final buf = StringBuffer();
    buf.writeln('abstract final class _Errors {');
    for (final name in usedNames) {
      final methodSource = registry[name];
      if (methodSource != null) {
        buf.writeln('  $methodSource');
        buf.writeln();
      }
    }
    buf.writeln('}');
    return buf.toString();
  }
}
