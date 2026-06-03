import 'package:test/test.dart';
import 'package:validasi_mcp/validasi_mcp.dart';

DocPage _page(String path, String title, String section,
    {String content = ''}) {
  return DocPage(
    path: path,
    title: title,
    section: section,
    rawMarkdown: content,
    headings: [],
    codeBlocks: [],
  );
}

void main() {
  group('DocsTools', () {
    late DocsTools tools;

    setUp(() {
      final pages = [
        _page('guide/getting-started', 'Getting Started', 'guide',
            content: '# Getting Started\n\nUse StringRules.minLength(3).'),
        _page('schemas/string', 'String Schema', 'schemas',
            content: '# String Schema\n\nStringRules has minLength.'),
      ];
      final index = DocsIndex(pages);
      tools = DocsTools(index: index);
    });

    group('search_docs', () {
      test('should return results for matching query', () async {
        final result =
            await tools.callTool('search_docs', {'query': 'StringRules'});
        expect(result['ok'], isTrue);
        final results = result['results'] as List;
        expect(results, isNotEmpty);
      });

      test('should return error for missing query', () async {
        final result = await tools.callTool('search_docs', {});
        expect(result['ok'], isFalse);
        expect((result['error'] as Map)['code'], equals('INVALID_ARGUMENT'));
      });

      test('should return error for empty query', () async {
        final result = await tools.callTool('search_docs', {'query': ''});
        expect(result['ok'], isFalse);
      });
    });

    group('get_page', () {
      test('should return page for valid path', () async {
        final result =
            await tools.callTool('get_page', {'path': 'guide/getting-started'});
        expect(result['ok'], isTrue);
        final page = result['page'] as Map;
        expect(page['title'], equals('Getting Started'));
        expect(page['content'], isNotEmpty);
      });

      test('should return error for missing path argument', () async {
        final result = await tools.callTool('get_page', {});
        expect(result['ok'], isFalse);
      });

      test('should return error for unknown path', () async {
        final result =
            await tools.callTool('get_page', {'path': 'nonexistent'});
        expect(result['ok'], isFalse);
        expect((result['error'] as Map)['code'], equals('NOT_FOUND'));
      });
    });

    group('list_pages', () {
      test('should return all pages grouped by section', () async {
        final result = await tools.callTool('list_pages', {});
        expect(result['ok'], isTrue);
        final sections = result['sections'] as List;
        expect(sections, hasLength(2));
      });

      test('should filter by section', () async {
        final result =
            await tools.callTool('list_pages', {'section': 'schemas'});
        expect(result['ok'], isTrue);
        final sections = result['sections'] as List;
        expect(sections, hasLength(1));
        expect((sections[0] as Map)['name'], equals('schemas'));
      });

      test('should return empty for unknown section', () async {
        final result =
            await tools.callTool('list_pages', {'section': 'unknown'});
        expect(result['ok'], isTrue);
        expect(result['sections'], isEmpty);
      });
    });

    group('get_code_examples', () {
      test('should return examples list', () async {
        final result = await tools.callTool('get_code_examples', {});
        expect(result['ok'], isTrue);
        expect(result['count'], equals(0));
      });
    });

    group('refresh_docs', () {
      test('should return unavailable when no fetcher configured', () async {
        final result = await tools.callTool('refresh_docs', {});
        expect(result['ok'], isFalse);
        expect((result['error'] as Map)['code'], equals('UNAVAILABLE'));
      });
    });

    group('clean_cache', () {
      test('should return unavailable when no fetcher configured', () async {
        final result = await tools.callTool('clean_cache', {});
        expect(result['ok'], isFalse);
        expect((result['error'] as Map)['code'], equals('UNAVAILABLE'));
      });
    });

    group('unknown tool', () {
      test('should return error for unknown tool', () async {
        final result = await tools.callTool('unknown', {});
        expect(result['ok'], isFalse);
        expect((result['error'] as Map)['code'], equals('UNKNOWN_TOOL'));
      });
    });
  });
}
