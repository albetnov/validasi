import 'package:validasi_mcp/src/docs_types.dart';

class DocsIndex {
  DocsIndex(this.pages) {
    _buildIndex();
  }

  final List<DocPage> pages;
  final Map<String, Set<String>> _wordIndex = {};
  final Map<String, DocPage> _pageByPath = {};

  DocPage? getPage(String path) => _pageByPath[path];

  List<DocPage> listPages({String? section}) {
    if (section == null) return List.unmodifiable(pages);
    return pages.where((p) => p.section == section).toList(growable: false);
  }

  List<DocSearchResult> search(String query) {
    final terms = _tokenize(query);
    if (terms.isEmpty) return [];

    final paths = <String>{};
    var first = true;
    for (final term in terms) {
      final matches = _wordIndex[term.toLowerCase()];
      if (matches == null) return [];
      if (first) {
        paths.addAll(matches);
        first = false;
      } else {
        paths.retainWhere((p) => matches.contains(p));
      }
    }

    final results = <_ScoredPage>[];
    for (final path in paths) {
      final page = _pageByPath[path]!;
      final score = _scorePage(page, terms);
      final snippet = _buildSnippet(page, terms);
      results.add(_ScoredPage(page, score, snippet));
    }

    results.sort((a, b) => b.score.compareTo(a.score));

    return results
        .take(10)
        .map((r) => DocSearchResult(
              path: r.page.path,
              title: r.page.title,
              section: r.page.section,
              snippet: r.snippet,
              score: r.score,
            ))
        .toList(growable: false);
  }

  List<DocCodeBlock> getCodeExamples({String? page, String? rule}) {
    var sourcePages = pages;

    if (page != null) {
      final p = _pageByPath[page];
      if (p == null) return [];
      sourcePages = [p];
    }

    final results = <DocCodeBlock>[];
    for (final p in sourcePages) {
      for (final block in p.codeBlocks) {
        if (rule != null) {
          final query = rule.toLowerCase();
          if (!block.code.toLowerCase().contains(query)) continue;
        }
        results.add(block);
      }
    }
    return results;
  }

  void _buildIndex() {
    for (final page in pages) {
      _pageByPath[page.path] = page;
      final words = _tokenize(page.rawMarkdown);
      final unique = words.map((w) => w.toLowerCase()).toSet();
      for (final word in unique) {
        _wordIndex.putIfAbsent(word, () => <String>{}).add(page.path);
      }
    }
  }

  double _scorePage(DocPage page, List<String> terms) {
    var score = 0.0;
    final lowerTitle = page.title.toLowerCase();

    for (final term in terms) {
      if (lowerTitle.contains(term.toLowerCase())) {
        score += 10.0;
      }

      final lowerContent = page.rawMarkdown.toLowerCase();
      final count = _countOccurrences(lowerContent, term.toLowerCase());
      score += count * 0.5;

      final lowerPath = page.path.toLowerCase();
      if (lowerPath.contains(term.toLowerCase())) {
        score += 5.0;
      }
    }

    return score;
  }

  String _buildSnippet(DocPage page, List<String> terms) {
    final content = page.rawMarkdown;
    final lines = content.split('\n');

    var bestLine = 0;
    var bestCount = 0;

    for (var i = 0; i < lines.length; i++) {
      final lineLower = lines[i].toLowerCase();
      var count = 0;
      for (final term in terms) {
        if (lineLower.contains(term.toLowerCase())) count++;
      }
      if (count > bestCount) {
        bestCount = count;
        bestLine = i;
      }
    }

    final start = (bestLine - 2).clamp(0, lines.length);
    final end = (bestLine + 3).clamp(0, lines.length);
    final snippet = lines.sublist(start, end).join('\n').trim();
    return snippet.length > 300 ? '${snippet.substring(0, 300)}...' : snippet;
  }

  List<String> _tokenize(String text) {
    return text
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s-]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 3)
        .toList(growable: false);
  }

  int _countOccurrences(String text, String term) {
    var count = 0;
    var start = 0;
    while (true) {
      final index = text.indexOf(term, start);
      if (index == -1) break;
      count++;
      start = index + term.length;
    }
    return count;
  }
}

class _ScoredPage {
  _ScoredPage(this.page, this.score, this.snippet);

  final DocPage page;
  final double score;
  final String snippet;
}
