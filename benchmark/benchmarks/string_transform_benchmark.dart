import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class StringTransformBenchmark extends BenchmarkBase {
  final schema = Validasi.string([
    Transform((value) => value?.trim()),
    Transform((value) => value?.toLowerCase()),
    StringRules.minLength(3),
  ]);

  StringTransformBenchmark() : super('StringTransform');

  @override
  void run() {
    schema.validate('  Hello World  ');
    schema.validate('Hi');
    schema.validate('');
  }
}
