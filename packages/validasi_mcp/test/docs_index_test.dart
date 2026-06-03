import 'package:test/test.dart';
import 'package:validasi_mcp/validasi_mcp.dart';

DocPage _page(String path, String title, String section, {String content = '', List<DocCodeBlock> codeBlocks = const []}) {
  return DocPage(
    path: path,
    title: title,
    section: section,
    rawMarkdown: content,
    headings: [],
    codeBlocks: codeBlocks,
  );
}

void main() {
  group('DocsIndex', () {
    late List<DocPage> samplePages;
    late DocsIndex index;

    setUp(() {
      samplePages = [
        _page('guide/getting-started', 'Getting Started', 'guide',
            content: '# Getting Started\n\nThis is the getting started guide.\n\nUse StringRules for string validation.'),
        _page('schemas/string', 'String Schema', 'schemas',
            content: '# String Schema\n\nStringRules has minLength and maxLength.\n\nUse StringRules.minLength(3) to validate.'),
        _page('schemas/number', 'Number Schema', 'schemas',
            content: '# Number Schema\n\nNumberRules has moreThan and lessThan.'),
        _page('advanced/engine', 'Engine Architecture', 'advanced',
            content: '# Engine\n\nThe validation engine processes rules in order.'),
      ];
      index = DocsIndex(samplePages);
    });

    group('getPage', () {
      test('should return page by path', () {
        final page = index.getPage('guide/getting-started');
        expect(page, isNotNull);
        expect(page!.title, equals('Getting Started'));
      });

      test('should return null for unknown path', () {
        expect(index.getPage('nonexistent'), isNull);
      });
    });

    group('listPages', () {
      test('should return all pages', () {
        final pages = index.listPages();
        expect(pages, hasLength(4));
      });

      test('should filter by section', () {
        final pages = index.listPages(section: 'schemas');
        expect(pages, hasLength(2));
        expect(pages[0].path, equals('schemas/string'));
        expect(pages[1].path, equals('schemas/number'));
      });

      test('should return empty for unknown section', () {
        final pages = index.listPages(section: 'unknown');
        expect(pages, isEmpty);
      });
    });

    group('search', () {
      test('should find pages by content', () {
        final results = index.search('validation');
        expect(results, isNotEmpty);
        expect(results.any((r) => r.path == 'guide/getting-started'), isTrue);
        expect(results.any((r) => r.path == 'advanced/engine'), isTrue);
      });

      test('should rank title matches higher', () {
        final results = index.search('string');
        expect(results, isNotEmpty);
        expect(results.first.path, equals('schemas/string'));
      });

      test('should return empty for no matches', () {
        final results = index.search('zzzznotfound');
        expect(results, isEmpty);
      });

      test('should handle short query terms', () {
        final results = index.search('a');
        expect(results, isEmpty);
      });

      test('should include snippet in results', () {
        final results = index.search('StringRules');
        expect(results, isNotEmpty);
        expect(results.first.snippet, isNotEmpty);
      });
    });

    group('getCodeExamples', () {
      test('should return code examples from all pages', () {
        final examples = index.getCodeExamples();
        expect(examples, hasLength(0)); // no code blocks in our test pages
      });

      test('should return matching code examples', () {
        final pagesWithCode = [
          _page('schemas/number', 'Number Schema', 'schemas',
              content: '# Number Schema',
              codeBlocks: [
                DocCodeBlock(language: 'dart', code: 'NumberRules.moreThan(0)', offset: 0),
              ]),
        ];
        final idx = DocsIndex(pagesWithCode);
        final examples = idx.getCodeExamples();
        expect(examples, hasLength(1));
      });

      test('should filter by rule keyword', () {
        final pagesWithCode = [
          _page('schemas/string', 'String Schema', 'schemas',
              content: '# String Schema',
              codeBlocks: [
                DocCodeBlock(language: 'dart', code: 'StringRules.minLength(3)', offset: 0),
                DocCodeBlock(language: 'dart', code: 'NumberRules.moreThan(0)', offset: 0),
              ]),
        ];
        final idx = DocsIndex(pagesWithCode);
        final examples = idx.getCodeExamples(rule: 'minLength');
        expect(examples, hasLength(1));
        expect(examples.first.code, contains('minLength'));
      });
    });
  });
}
