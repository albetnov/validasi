import 'package:validasi/src/rules/string/rules.dart' as string;
import 'package:validasi/src/rules/iterable/rules.dart' as iterable;
import 'package:validasi/validasi.dart';

void main(List<String> args) {
  final schema = Validasi.list<List<String>>([
    iterable.ForEach(
      Validasi.list<String>(
        [
          iterable.ForEach(
            Validasi.string([string.MinLength(1, message: 'required')]),
          ),
        ],
      ),
    ),
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
