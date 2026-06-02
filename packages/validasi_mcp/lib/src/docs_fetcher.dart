import 'dart:convert';
import 'dart:io';

import 'package:validasi_mcp/src/docs_types.dart';

class DocsFetcher {
  DocsFetcher({required this.config});

  final DocsConfig config;

  String get _cacheDir => config.resolvedCacheDir;
  String get _manifestPath => '$_cacheDir/.llms.txt';

  Future<List<String>> fetchPageList() async {
    final url = '${config.baseUrl}/llms.txt';
    final body = await _httpGet(url);

    return body
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(_pathFromUrl)
        .where((path) => !path.startsWith('v0/'))
        .toList(growable: false);
  }

  Future<DocPage> fetchPage(String path) async {
    final url = '${config.baseUrl}/$path.md';
    final raw = await _httpGet(url);
    return _parsePage(path, raw);
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
      pages.add(_parsePage(path, raw));
    }

    return pages;
  }

  Future<void> clearCache() async {
    final dir = Directory(_cacheDir);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
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
    path = path.replaceAll(RegExp(r'\.md$'), '');
    return path;
  }

  String _sectionFromPath(String path) {
    final parts = path.split('/');
    return parts.length > 1 ? parts.first : '';
  }

  DocPage _parsePage(String path, String raw) {
    final lines = raw.split('\n');
    final title = _extractTitle(lines);
    final headings = _extractHeadings(lines);
    final codeBlocks = _extractCodeBlocks(lines);
    final section = _sectionFromPath(path);

    return DocPage(
      path: path,
      title: title,
      section: section,
      rawMarkdown: raw,
      headings: headings,
      codeBlocks: codeBlocks,
    );
  }

  String _extractTitle(List<String> lines) {
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('# ')) {
        return trimmed.substring(2).trim();
      }
    }
    return '';
  }

  List<DocHeading> _extractHeadings(List<String> lines) {
    final headings = <DocHeading>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final match = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);
      if (match != null) {
        headings.add(DocHeading(
          level: match.group(1)!.length,
          text: match.group(2)!.trim(),
          offset: i,
        ));
      }
    }
    return headings;
  }

  List<DocCodeBlock> _extractCodeBlocks(List<String> lines) {
    final blocks = <DocCodeBlock>[];
    var i = 0;
    while (i < lines.length) {
      final match = RegExp(r'^```(\w*)$').firstMatch(lines[i].trim());
      if (match != null) {
        final language = match.group(1) ?? '';
        final start = i;
        i++;
        final codeLines = <String>[];
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        blocks.add(DocCodeBlock(
          language: language,
          code: codeLines.join('\n'),
          offset: start,
        ));
      }
      i++;
    }
    return blocks;
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
