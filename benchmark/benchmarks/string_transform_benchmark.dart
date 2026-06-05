import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class StringTransformBenchmark extends BenchmarkBase {
  final schema = Validasi.string([
    Rules.transform<String>((value) => value?.trim()),
    Rules.transform<String>((value) => value?.toLowerCase()),
    Rules.string.minLength(3),
  ]);

  StringTransformBenchmark() : super('StringTransform');

  @override
  void run() {
    schema.validate('  Hello World  ');
    schema.validate('Hi');
    schema.validate('');
  }
}
