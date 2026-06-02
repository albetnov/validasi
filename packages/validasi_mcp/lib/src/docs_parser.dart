import 'package:validasi_mcp/src/docs_types.dart';

class DocPageParser {
  static DocPage parse(String path, String raw) {
    final lines = raw.split('\n');
    return DocPage(
      path: path,
      title: _extractTitle(lines),
      section: _sectionFromPath(path),
      rawMarkdown: raw,
      headings: _extractHeadings(lines),
      codeBlocks: _extractCodeBlocks(lines),
    );
  }

  static String _extractTitle(List<String> lines) {
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('# ')) {
        return trimmed.substring(2).trim();
      }
    }
    return '';
  }

  static List<DocHeading> _extractHeadings(List<String> lines) {
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

  static List<DocCodeBlock> _extractCodeBlocks(List<String> lines) {
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

  static String _sectionFromPath(String path) {
    final parts = path.split('/');
    return parts.length > 1 ? parts.first : '';
  }
}
