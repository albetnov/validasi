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

class RuleInfo {
  final String name;
  final Map<String, Object?> params;
  final String? message;
  final bool isUnknown;
  final DartType? typeArg;
  RuleInfo(this.name, this.params, this.message, {this.isUnknown = false, this.typeArg});
}

abstract class RuleGen {
  bool get isControl => false;
  String get name;
  RuleInfo parse(ConstantReader rule);
  String check(RuleInfo info, String fieldName);
  String defaultMessage(RuleInfo info, [String context = '']);
  String? details(RuleInfo info);

  void validateType(DartType? typeArg, FieldElement field) {}
}
