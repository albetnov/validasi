import 'package:validasi/src/rules/string/rules.dart' as string_rules;
import 'package:validasi/src/rules/iterable/rules.dart' as iterable_rules;
import 'package:validasi/validasi.dart';

void main(List<String> args) {
  final schema = Validasi.list<String>([
    iterable_rules.ForEach(
      Validasi.string(
        [
          string_rules.MinLength(1, message: 'Item must not be empty'),
        ],
      ),
    ),
    iterable_rules.MinLength(3),
  ]);

  final result = schema.validate(['']);

  print("isValid: ${result.isValid}, "
      "errors: ${result.errors.map((e) => e.message).join(', ')}, "
      "value: ${result.data}, type: ${result.data.runtimeType}");
}
