import 'package:validasi_mcp/validasi_mcp.dart';

Future<void> main(List<String> args) async {
  if (args.contains('--clean-cache')) {
    final config = DocsConfig(
      cacheDir: _argValue(args, '--cache-dir'),
    );
    await DocsFetcher(config: config).clearCache();
    print('Cache cleared.');
    return;
  }

  print('validasi_mcp server will start here.');
}

String? _argValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) return null;
  return args[index + 1];
}
