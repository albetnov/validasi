import 'dart:convert';
import 'dart:io';

import 'package:validasi_mcp/src/docs_parser.dart';
import 'package:validasi_mcp/src/docs_types.dart';

class DocsFetcher {
  DocsFetcher({required this.config});

  final DocsConfig config;

  String get _cacheDir => config.resolvedCacheDir;
  String get _manifestPath => '$_cacheDir/.llms.txt';

  Future<List<String>> fetchPageList() async {
    final url = '${config.baseUrl}/llms.txt';
    final body = await _httpGet(url);

    final linkPattern = RegExp(r'\[.+?\]\((/validasi/[^)]+?\.md)\)');
    final paths = <String>{};
    for (final match in linkPattern.allMatches(body)) {
      final raw = match.group(1)!;
      final path = _pathFromUrl(raw);
      if (path.startsWith('v0/') ||
          path == 'markdown-examples' ||
          path == 'guide/agent-native-support') continue;
      paths.add(path);
    }

    return paths.toList(growable: false)..sort();
  }

  Future<DocPage> fetchPage(String path) async {
    final url = '${config.baseUrl}/$path.md';
    final raw = await _httpGet(url);
    return DocPageParser.parse(path, raw);
  }

  Future<void> ensureCached() async {
    final dir = Directory(_cacheDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    List<String> paths;
    if (File(_manifestPath).existsSync() && _isFresh(_manifestPath)) {
      paths = File(_manifestPath)
          .readAsLinesSync()
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && !l.startsWith('v0/'))
          .toList(growable: false);
    } else {
      paths = await fetchPageList();
      File(_manifestPath).writeAsStringSync(paths.join('\n'));
    }

    for (final path in paths) {
      final filePath = '$_cacheDir/$path.md';
      final file = File(filePath);

      if (file.existsSync() && _isFresh(filePath)) {
        continue;
      }

      file.parent.createSync(recursive: true);
      final raw = await fetchPage(path);
      file.writeAsStringSync(raw.rawMarkdown);
    }
  }

  Future<List<DocPage>> loadAllCached() async {
    final manifestFile = File(_manifestPath);
    if (!manifestFile.existsSync()) return [];

    final paths = manifestFile
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('v0/'));

    final pages = <DocPage>[];
    for (final path in paths) {
      final file = File('$_cacheDir/$path.md');
      if (!file.existsSync()) continue;

      final raw = await file.readAsString();
      pages.add(DocPageParser.parse(path, raw));
    }

    return pages;
  }

  Future<void> clearCache() async {
    final dir = Directory(_cacheDir);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  Future<List<DocPage>> refreshAll() async {
    await clearCache();
    await ensureCached();
    return loadAllCached();
  }

  bool _isFresh(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return false;

    final modified = file.statSync().modified;
    return DateTime.now().difference(modified) < config.cacheTtl;
  }

  String _pathFromUrl(String url) {
    final base = config.baseUrl;
    String path = url;
    if (path.startsWith(base)) {
      path = path.substring(base.length);
    }
    path = path.replaceAll(RegExp(r'^/+'), '');
    path = path.replaceAll(RegExp(r'^validasi/'), '');
    path = path.replaceAll(RegExp(r'\.md$'), '');
    return path;
  }

  Future<String> _httpGet(String url) async {
    final uri = Uri.parse(url);
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to fetch $url: ${response.statusCode}',
          uri: uri,
        );
      }
      return body;
    } finally {
      client.close();
    }
  }
}
