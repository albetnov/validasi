import 'package:source_gen/source_gen.dart';

class RuleInfo {
  final String name;
  final Map<String, Object?> params;
  final String? message;
  final bool isUnknown;
  RuleInfo(this.name, this.params, this.message, {this.isUnknown = false});
}

abstract class RuleGen {
  bool get isControl => false;
  String get name;
  RuleInfo parse(ConstantReader rule);
  String check(RuleInfo info, String fieldName);
  String defaultMessage(RuleInfo info, [String context = '']);
  String? details(RuleInfo info);
}
