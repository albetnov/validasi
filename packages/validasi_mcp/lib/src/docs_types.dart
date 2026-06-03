class DocsConfig {
  DocsConfig({
    this.baseUrl = 'https://albetnov.github.io/validasi',
    this.cacheDir,
    this.cacheTtl = const Duration(hours: 24),
  });

  final String baseUrl;
  final String? cacheDir;
  final Duration cacheTtl;

  String get resolvedCacheDir => cacheDir ?? '.validasi_mcp_cache';
}

class DocPage {
  DocPage({
    required this.path,
    required this.title,
    required this.rawMarkdown,
    this.section = '',
    this.headings = const [],
    this.codeBlocks = const [],
  });

  final String path;
  final String title;
  final String section;
  final String rawMarkdown;
  final List<DocHeading> headings;
  final List<DocCodeBlock> codeBlocks;
}

class DocHeading {
  DocHeading({required this.level, required this.text, this.offset = 0});

  final int level;
  final String text;
  final int offset;
}

class DocCodeBlock {
  DocCodeBlock({
    this.language = '',
    required this.code,
    this.offset = 0,
  });

  final String language;
  final String code;
  final int offset;
}

class DocSearchResult {
  DocSearchResult({
    required this.path,
    required this.title,
    required this.section,
    required this.snippet,
    this.score = 0.0,
  });

  final String path;
  final String title;
  final String section;
  final String snippet;
  final double score;
}
