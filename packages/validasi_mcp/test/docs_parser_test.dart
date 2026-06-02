import 'package:test/test.dart';
import 'package:validasi_mcp/validasi_mcp.dart';

void main() {
  group('DocPageParser', () {
    test('should parse title from first h1 heading', () {
      final raw = '''
# Getting Started

Some intro text.

## Installation

Installation steps.
''';
      final page = DocPageParser.parse('guide/getting-started', raw);
      expect(page.title, equals('Getting Started'));
      expect(page.section, equals('guide'));
    });

    test('should return empty title when no h1 exists', () {
      final raw = 'Just some text without headings.';
      final page = DocPageParser.parse('readme', raw);
      expect(page.title, isEmpty);
    });

    test('should extract all headings with levels', () {
      final raw = '''
# Title
## Section 1
### Subsection 1.1
## Section 2
''';
      final page = DocPageParser.parse('test', raw);
      expect(page.headings, hasLength(4));
      expect(page.headings[0].text, equals('Title'));
      expect(page.headings[0].level, equals(1));
      expect(page.headings[1].text, equals('Section 1'));
      expect(page.headings[1].level, equals(2));
      expect(page.headings[2].text, equals('Subsection 1.1'));
      expect(page.headings[2].level, equals(3));
    });

    test('should extract fenced code blocks with language', () {
      final raw = '''
# Example

Some text.

```dart
final x = 1;
print(x);
```

More text.

```yaml
name: test
version: 1.0.0
```
''';
      final page = DocPageParser.parse('test', raw);
      expect(page.codeBlocks, hasLength(2));
      expect(page.codeBlocks[0].language, equals('dart'));
      expect(page.codeBlocks[0].code, equals('final x = 1;\nprint(x);'));
      expect(page.codeBlocks[1].language, equals('yaml'));
      expect(page.codeBlocks[1].code, equals('name: test\nversion: 1.0.0'));
    });

    test('should handle code blocks without language', () {
      final raw = '''
```
plain code block
```
''';
      final page = DocPageParser.parse('test', raw);
      expect(page.codeBlocks, hasLength(1));
      expect(page.codeBlocks[0].language, isEmpty);
      expect(page.codeBlocks[0].code, equals('plain code block'));
    });

    test('should skip inline backticks', () {
      final raw = '''
# Title

Use `StringRules.minLength()` to validate.
''';
      final page = DocPageParser.parse('test', raw);
      expect(page.codeBlocks, isEmpty);
    });

    test('should determine section from path', () {
      final page = DocPageParser.parse('schemas/string', '# String Schema');
      expect(page.section, equals('schemas'));
    });

    test('should handle empty section', () {
      final page = DocPageParser.parse('index', '# Home');
      expect(page.section, isEmpty);
    });

    test('should preserve raw markdown', () {
      final raw = '# Title\n\nSome content.';
      final page = DocPageParser.parse('test', raw);
      expect(page.rawMarkdown, equals(raw));
    });
  });
}
