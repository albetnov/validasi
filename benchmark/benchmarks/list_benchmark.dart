import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class ListBenchmark extends BenchmarkBase {
  final schema = Validasi.list<String>([
    Rules.iterable.minLength(1),
    Rules.iterable.forEach<String>([
      Rules.string.minLength(2),
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
