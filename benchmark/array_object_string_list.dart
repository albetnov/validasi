import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';
import 'package:validasi/src/rules/list_rules.dart';
import 'package:validasi/src/rules/string_rules.dart';

void main() {
  // Old (naive engine)
  final oldValidator = Validasi.list([
    IterableRules.forEach(Validasi.string([
      StringRules.minLength(2),
      StringRules.maxLength(10),
    ])),
  ]);

  // New (compiler-based)
  final newValidator = ValidasiExecutor.list([
    ListForEachRule<String>([
      StringMinLengthRule(2),
      StringMaxLengthRule(10),
    ]),
  ]);

  final payload = ['hello', 'world', 'foo', 'ab', 'test123'];

  // Benchmark old implementation
  final duration = Duration(seconds: 1);
  int iterationCount = 0;
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsed < duration) {
    oldValidator.validate(payload);
    iterationCount++;
  }

  print(
      'String/List Old: Processed $iterationCount iterations in ${duration.inSeconds} seconds');

  // Benchmark new implementation
  iterationCount = 0;
  stopwatch
    ..reset()
    ..start();
  while (stopwatch.elapsed < duration) {
    newValidator.validate(payload);
    iterationCount++;
  }
  print(
      'String/List New: Processed $iterationCount iterations in ${duration.inSeconds} seconds');
}
