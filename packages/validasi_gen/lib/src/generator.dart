import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'package:validasi_gen/src/generators/cross_fields.dart';
import 'package:validasi_gen/src/generators/extension.dart';
import 'package:validasi_gen/src/generators/fields_class.dart';
import 'package:validasi_gen/src/parsers/rules.dart';
import 'package:validasi_gen/src/utils.dart';

class ValidasiGenerator extends Generator {
  ValidasiGenerator({this.generateFieldsDefault = true});

  final bool generateFieldsDefault;

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

      final crossFields = extractCrossFields(cls);

      if (generateFields) {
        buffer.write(
            generateFieldsClass(cls.name!, fields, crossFields: crossFields));
        buffer.write(generateFromForm(cls.name!, fields));
      }

      if (crossFields.isNotEmpty) {
        buffer.write(generateCrossFieldsClass(cls.name!, crossFields));
      }

      buffer.write(generateValidateExtension(
        cls.name!,
        fields,
        includeValidateField: generateFields,
      ));
    }

    return buffer.toString();
  }

  void _detectCycles(
      Map<String, ClassElement> validateClasses, LibraryReader library) {
    final graph = <String, Set<String>>{};

    // 1. Build Adjacency List
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

    // 2. Run DFS
    for (final className in graph.keys) {
      if (_dfsCycle(className, graph, visited, inStack, path)) {
        // The last item added is the node that triggered the loop
        final duplicateNode = path.last;

        // Find where that node first appeared in our current tracking path
        final cycleStart = path.indexOf(duplicateNode);

        // Slice out ONLY the participating members of the cycle
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
      path.add(node); // Append the "closer" node to complete the visual trace
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

    // Backtrack
    inStack.remove(node);
    path.removeLast();
    return false;
  }
}
