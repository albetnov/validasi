import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

bool hasValidateClassAnnotation(ClassElement cls) {
  return cls.metadata.any((meta) {
    final element = meta.element;
    return element is ConstructorElement &&
        element.enclosingElement.name == 'ValidateClass';
  });
}

(String className, bool isIterable)? detectNestedField(
    FieldElement field, LibraryReader library) {
  final type = field.type;

  if (type.isDartCoreMap) return null;

  if (type is InterfaceType) {
    final typeName = type.element.name;
    if (typeName == 'List' || typeName == 'Iterable' || typeName == 'Set') {
      if (type.typeArguments.isNotEmpty) {
        final elementType = type.typeArguments.first;
        final elementClass = getClassFromType(elementType);
        if (elementClass != null && hasValidateClassAnnotation(elementClass)) {
          return (elementClass.name, true);
        }
      }
    }
  }

  final directClass = getClassFromType(type);
  if (directClass != null && hasValidateClassAnnotation(directClass)) {
    return (directClass.name, false);
  }

  return null;
}

ClassElement? getClassFromType(DartType type) {
  final element = type.element;
  if (element is ClassElement) return element;
  return null;
}
