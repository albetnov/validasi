import 'package:validasi_mcp/validasi_mcp.dart';

Future<void> main(List<String> args) async {
  final cacheDir = _argValue(args, '--cache-dir');
  final forceRefresh = args.contains('--refresh');

  if (args.contains('--clean-cache')) {
    await DocsFetcher(config: DocsConfig(cacheDir: cacheDir)).clearCache();
    print('Cache cleared.');
    return;
  }

  final config = DocsConfig(
    cacheDir: cacheDir,
    cacheTtl: forceRefresh ? Duration.zero : const Duration(hours: 24),
  );
  final fetcher = DocsFetcher(config: config);

  if (forceRefresh) {
    await fetcher.clearCache();
  }

  await fetcher.ensureCached();

  final pages = await fetcher.loadAllCached();
  final index = DocsIndex(pages);
  final tools = DocsTools(index: index);
  final server = ValidasiMcpStdioServer(
    tools: tools,
    config: config,
    docsPages: pages,
  );

  await server.serve();
}

String? _argValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) return null;
  return args[index + 1];
}
