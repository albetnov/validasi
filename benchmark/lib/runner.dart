import 'package:benchmark_harness/benchmark_harness.dart';

class BenchmarkRegistry {
  static final Map<String, BenchmarkBase Function()> _entries = {};

  static void register(String name, BenchmarkBase Function() factory) {
    _entries[name] = factory;
  }

  static List<String> get names => _entries.keys.toList();

  static void runAll({List<String>? filter}) {
    final selected = filter ?? _entries.keys.toList();

    for (final name in selected) {
      final factory = _entries[name];

      if (factory == null) {
        print('Unknown benchmark: $name');
        continue;
      }

      print('--- $name ---');
      factory().report();
      print('');
    }
  }
}
