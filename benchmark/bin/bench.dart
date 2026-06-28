import '../lib/runner.dart';
import '../benchmarks/string_benchmark.dart';
import '../benchmarks/number_benchmark.dart';
import '../benchmarks/string_transform_benchmark.dart';
import '../benchmarks/list_benchmark.dart';
import '../benchmarks/map_benchmark.dart';
import '../benchmarks/nested_map_benchmark.dart';
import '../benchmarks/preprocess_benchmark.dart';
import '../benchmarks/hasfields_comparison_benchmark.dart';

void main(List<String> args) {
  BenchmarkRegistry.register('string', () => StringBenchmark());
  BenchmarkRegistry.register('number', () => NumberBenchmark());
  BenchmarkRegistry.register(
      'string_transform', () => StringTransformBenchmark());
  BenchmarkRegistry.register('list', () => ListBenchmark());
  BenchmarkRegistry.register('map', () => MapBenchmark());
  BenchmarkRegistry.register('nested_map', () => NestedMapBenchmark());
  BenchmarkRegistry.register('preprocess', () => PreprocessBenchmark());
  BenchmarkRegistry.register(
      'fieldrules_vs_engine', () => FieldRulesBenchmark());
  BenchmarkRegistry.register(
      'engine_vs_fieldrules', () => EngineHasFieldsBenchmark());

  if (args.contains('--list') || args.contains('-l')) {
    print('Available benchmarks:');
    for (final name in BenchmarkRegistry.names) {
      print('  $name');
    }
    return;
  }

  if (args.contains('--help') || args.contains('-h')) {
    print('Usage: dart run bin/bench.dart [benchmark_names]');
    print('');
    print('  benchmark_names   Comma-separated list of benchmarks to run.');
    print('                    If omitted, all benchmarks are run.');
    print('');
    print('  --list, -l        List available benchmarks.');
    print('  --help, -h        Show this help message.');
    print('');
    print('Examples:');
    print('  dart run bin/bench.dart');
    print('  dart run bin/bench.dart string,map');
    print('  dart run bin/bench.dart --list');
    return;
  }

  List<String>? filter;

  if (args.isNotEmpty && !args.first.startsWith('-')) {
    filter = args.first.split(',').map((s) => s.trim()).toList();
  }

  BenchmarkRegistry.runAll(filter: filter);
}
