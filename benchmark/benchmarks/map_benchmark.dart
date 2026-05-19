import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

class MapBenchmark extends BenchmarkBase {
  final schema = Validasi.map<dynamic>([
    MapRules.hasFields<dynamic>({
      'name': Validasi.string([
        StringRules.minLength(2),
        StringRules.maxLength(50),
      ]),
      'age': Validasi.number<int>([
        NumberRules.moreThanEqual(0),
        NumberRules.lessThan(150),
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
