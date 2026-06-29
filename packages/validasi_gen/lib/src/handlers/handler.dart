import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

enum FieldContext { string, iterable, generic }

FieldContext fieldContextFromType(DartType? type) {
  if (type == null) return FieldContext.generic;
  if (type.isDartCoreString) return FieldContext.string;
  if (type is InterfaceType) {
    final name = type.element.name;
    if (name == 'Iterable' || name == 'List' || name == 'Set') {
      return FieldContext.iterable;
    }
  }
  return FieldContext.generic;
}

class RuleInfo {
  final String name;
  final Map<String, Object?> params;
  final String? message;
  final bool isUnknown;
  final bool isAsync;
  final String? functionName;
  RuleInfo(
    this.name,
    this.params,
    this.message, {
    this.isUnknown = false,
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
  String defaultMessage(RuleInfo info,
      [FieldContext context = FieldContext.string]);
  String? asyncCall(RuleInfo info, String fieldName) => null;

  /// Returns the Dart expression for the error call, e.g.
  /// `_Errors.minLength(path, 3, message: '...')`.
  /// [messageArg] is pre-formatted with leading `, message:` when non-empty.
  String emitError(RuleInfo info, String pathExpr, String messageArg,
      [FieldContext context = FieldContext.string]);

  /// Map of helper method name to its source code (body of a static method
  /// in the generated `_Errors` class).
  Map<String, String> get helperMethods;

  Set<FieldContext> get supportedContexts => {FieldContext.generic};

  void validateType(FieldContext context, FieldElement field) {}
}
