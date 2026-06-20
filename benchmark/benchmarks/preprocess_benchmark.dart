import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class PreprocessBenchmark extends BenchmarkBase {
  final schema = Validasi.number<int>([
    Rules.number.moreThanEqual(0),
    Rules.number.lessThan(150),
  ]).withPreprocess<String>(
    (value) => int.tryParse(value) ?? -1,
    message: 'Failed to parse integer',
  );

  PreprocessBenchmark() : super('Preprocess');

  @override
  void run() {
    schema.validate('42');
    schema.validate('0');
    schema.validate('149');
  }
}
