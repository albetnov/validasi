import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

DartType? typeArgOf(ConstantReader rule) {
  final type = rule.objectValue.type;
  if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
    return type.typeArguments.first;
  }
  return null;
}

DartType? typeArgOfBase(ConstantReader rule, String baseName) {
  final type = rule.objectValue.type;
  if (type is InterfaceType) {
    for (final supertype in type.allSupertypes) {
      if (supertype.element.name == baseName &&
          supertype.typeArguments.isNotEmpty) {
        return supertype.typeArguments.first;
      }
    }
  }
  return null;
}

class RuleInfo {
  final String name;
  final Map<String, Object?> params;
  final String? message;
  final bool isUnknown;
  final DartType? typeArg;
  final bool isAsync;
  final String? functionName;
  RuleInfo(
    this.name,
    this.params,
    this.message, {
    this.isUnknown = false,
    this.typeArg,
    this.isAsync = false,
    this.functionName,
  });
}

abstract class RuleGen {
  bool get isControl => false;
  bool get isAsync => false;
  String get name;
  RuleInfo parse(ConstantReader rule);
  String check(RuleInfo info, String fieldName, {bool nullable = true});
  String defaultMessage(RuleInfo info, [String context = '']);
  String? asyncCall(RuleInfo info, String fieldName) => null;

  /// Returns the Dart expression for the error call, e.g.
  /// `_Errors.minLength(path, 3, message: '...')`.
  /// [messageArg] is pre-formatted with leading `, message:` when non-empty.
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [String context = '']);

  /// Map of helper method name to its source code (body of a static method
  /// in the generated `_Errors` class).
  Map<String, String> get helperMethods;

  void validateType(DartType? typeArg, FieldElement field) {}
}
