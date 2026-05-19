import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class ListBenchmark extends BenchmarkBase {
  final schema = Validasi.list<String>([
    IterableRules.minLength(1),
    IterableRules.forEach<String>([
      StringRules.minLength(2),
    ]),
  ]);

  ListBenchmark() : super('List');

  @override
  void run() {
    schema.validate(['abc', 'de', 'fgh']);
    schema.validate(<String>[]);
    schema.validate(['a', 'bc', 'def']);
  }
}
