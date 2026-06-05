import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class MapBenchmark extends BenchmarkBase {
  final schema = Validasi.map<dynamic>([
    Rules.map.hasFields({
      'name': FieldRules<String>([
        Rules.string.minLength(2),
        Rules.string.maxLength(50),
      ]),
      'age': FieldRules<int>([
        Rules.number.moreThanEqual(0),
        Rules.number.lessThan(150),
      ]),
    }),
  ]);

  MapBenchmark() : super('Map');

  @override
  void run() {
    schema.validate({'name': 'Alice', 'age': 30});
    schema.validate({'name': 'A', 'age': -1});
    schema.validate({'name': 'Bob'});
  }
}
