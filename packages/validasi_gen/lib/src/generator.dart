import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'package:validasi_gen/src/generators/cross_fields.dart';
import 'package:validasi_gen/src/generators/extension.dart';
import 'package:validasi_gen/src/generators/fields_class.dart';
import 'package:validasi_gen/src/generators/form_validator.dart';
import 'package:validasi_gen/src/parsers/rules.dart';
import 'package:validasi_gen/src/utils.dart';

class ValidasiGenerator extends Generator {
  ValidasiGenerator({
    this.generateFieldsDefault = true,
    this.generateAssembleDefault = true,
    this.generateValidateFormDefault = false,
    this.generateIndexedFieldsDefault = false,
  });

  final bool generateFieldsDefault;
  final bool generateAssembleDefault;
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
      if (fields.isEmpty) continue;

      final generateFields =
          readGenerateFieldsOverride(cls) ?? generateFieldsDefault;
      final generateAssemble =
          readGenerateAssembleOverride(cls) ?? generateAssembleDefault;
      final generateIndexedFields = readGenerateIndexedFieldsOverride(cls) ??
          generateIndexedFieldsDefault;
      final refines = extractRefineMethods(cls);
      final shouldEmitValidateForm =
          generateFields && generateValidateFormDefault;

      if (generateFields) {
        buffer.write(generateFieldsClass(
          cls.name!,
          fields,
          generateIndexedFields: generateIndexedFields,
        ));
        if (generateAssemble) {
          buffer.write(generateFromForm(cls.name!, fields));
        }
      }

      buffer.write(generateValidateExtension(
        cls.name!,
        fields,
        includeValidateField: generateFields,
        refines: refines,
      ));

      if (shouldEmitValidateForm) {
        buffer.write(generateValidateForm(cls.name!, fields, refines: refines));
      }
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
}
