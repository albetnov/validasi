import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

void main(List<String> args) {
  final schema = Validasi.list<List<String>>([
    IterableRules.forEach<List<String>>([
      IterableRules.forEach<String>([
        StringRules.minLength(1, message: 'required'),
      ]),
    ]),
  ]);

  final result = schema.validate([
    ['abc', 'def'],
    ['ghi', 'jkl', ''],
    ['']
  ]);

  print("isValid: ${result.isValid}, "
      "errors: ${result.errors.map((e) => "${e.path?.join(':')} ${e.message}").join(', ')}, "
      "value: ${result.data}, type: ${result.data.runtimeType}");
}
