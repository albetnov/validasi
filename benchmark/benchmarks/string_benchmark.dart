import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class StringBenchmark extends BenchmarkBase {
  final schema = Validasi.string([
    StringRules.minLength(3),
    StringRules.maxLength(16),
  ]);

  StringBenchmark() : super('String');

  @override
  void run() {
    schema.validate('Hello');
    schema.validate('Hi');
    schema.validate('A very long string indeed');
  }
}
