import 'package:source_gen/source_gen.dart';
import 'package:validasi_gen/src/handlers/handler.dart';

class MaxLengthGen extends RuleGen {
  @override
  String get name => 'MaxLength';

  @override
  RuleInfo parse(ConstantReader rule) {
    final length = rule.read('length').intValue;
    return RuleInfo(
        'MaxLength', {'length': length}, rule.peek('message')?.stringValue);
  }

  @override
  String check(RuleInfo info, String fieldName) {
    final length = info.params['length'] as int;
    return '$fieldName != null && $fieldName.length > $length';
  }

  @override
  String defaultMessage(RuleInfo info) {
    return 'Maximum length is ${info.params['length']} characters';
  }

  @override
  String? details(RuleInfo info) {
    return "{'length': '${info.params['length']}'}";
  }
}
