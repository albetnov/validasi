import 'package:dart_mcp/server.dart';
import 'package:validasi_mcp/src/docs_index.dart';

class DocsTools {
  DocsTools({required this.index});

  final DocsIndex index;

  Map<String, Object?> callTool(String name, Map<String, Object?> arguments) {
    switch (name) {
      case 'search_docs':
        return searchDocs(arguments);
      case 'get_page':
        return getPage(arguments);
      case 'list_pages':
        return listPages(arguments);
      case 'get_code_examples':
        return getCodeExamples(arguments);
      default:
        return _error('UNKNOWN_TOOL', 'Unknown tool: $name');
    }
  }

  Map<String, Object?> searchDocs(Map<String, Object?> arguments) {
    final query = arguments['query'];
    if (query is! String || query.trim().isEmpty) {
      return _error('INVALID_ARGUMENT', 'query is required and must be a non-empty string');
    }

    final results = index.search(query.trim());
    return {
      'ok': true,
      'results': results
          .map((r) => {
                'path': r.path,
                'title': r.title,
                'section': r.section,
                'snippet': r.snippet,
                'score': r.score,
              })
          .toList(growable: false),
    };
  }

  Map<String, Object?> getPage(Map<String, Object?> arguments) {
    final path = arguments['path'];
    if (path is! String || path.trim().isEmpty) {
      return _error('INVALID_ARGUMENT', 'path is required and must be a non-empty string');
    }

    final page = index.getPage(path.trim());
    if (page == null) {
      return _error('NOT_FOUND', 'Page not found: $path');
    }

    return {
      'ok': true,
      'page': {
        'path': page.path,
        'title': page.title,
        'section': page.section,
        'content': page.rawMarkdown,
        'headings': page.headings
            .map((h) => {
                  'level': h.level,
                  'text': h.text,
                })
            .toList(growable: false),
      },
    };
  }

  Map<String, Object?> listPages(Map<String, Object?> arguments) {
    final section = arguments['section'] as String?;

    final pages = index.listPages(section: section);

    final Map<String, List<Map<String, String>>> grouped = {};
    for (final page in pages) {
      grouped.putIfAbsent(page.section, () => []).add({
        'path': page.path,
        'title': page.title,
      });
    }

    return {
      'ok': true,
      'sections': grouped.entries.map((e) {
        return {
          'name': e.key,
          'pages': e.value,
        };
      }).toList(growable: false),
    };
  }

  Map<String, Object?> getCodeExamples(Map<String, Object?> arguments) {
    final page = arguments['page'] as String?;
    final rule = arguments['rule'] as String?;

    final examples = index.getCodeExamples(page: page, rule: rule);

    return {
      'ok': true,
      'count': examples.length,
      'examples': examples
          .map((e) => {
                'language': e.language,
                'code': e.code,
              })
          .toList(growable: false),
    };
  }

  List<Tool> tools() {
    return [
      Tool(
        name: 'search_docs',
        description: 'Search Validasi documentation pages by query text',
        inputSchema: ObjectSchema.fromMap({
          'type': 'object',
          'required': ['query'],
          'properties': {
            'query': {'type': 'string', 'description': 'Search query text'},
          },
          'additionalProperties': false,
        }),
      ),
      Tool(
        name: 'get_page',
        description: 'Retrieve a full documentation page by its path',
        inputSchema: ObjectSchema.fromMap({
          'type': 'object',
          'required': ['path'],
          'properties': {
            'path': {
              'type': 'string',
              'description': 'Page path, e.g. guide/getting-started',
            },
          },
          'additionalProperties': false,
        }),
      ),
      Tool(
        name: 'list_pages',
        description: 'List all available documentation pages, optionally filtered by section',
        inputSchema: ObjectSchema.fromMap({
          'type': 'object',
          'properties': {
            'section': {
              'type': 'string',
              'description': 'Filter by section (guide, schemas, advanced)',
            },
          },
          'additionalProperties': false,
        }),
      ),
      Tool(
        name: 'get_code_examples',
        description: 'Retrieve code examples from documentation pages',
        inputSchema: ObjectSchema.fromMap({
          'type': 'object',
          'properties': {
            'page': {'type': 'string', 'description': 'Filter by page path'},
            'rule': {'type': 'string', 'description': 'Filter by rule name or keyword'},
          },
          'additionalProperties': false,
        }),
      ),
    ];
  }

  Map<String, Object?> _error(String code, String message) {
    return {
      'ok': false,
      'error': {'code': code, 'message': message},
    };
  }
}
