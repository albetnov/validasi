import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class NumberBenchmark extends BenchmarkBase {
  final schema = Validasi.number<int>([
    NumberRules.moreThanEqual(0),
    NumberRules.lessThan(100),
  ]);

  NumberBenchmark() : super('Number');

  @override
  void run() {
    schema.validate(50);
    schema.validate(-1);
    schema.validate(99);
  }
}
