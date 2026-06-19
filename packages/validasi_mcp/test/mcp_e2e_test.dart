import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  late Directory cacheDir;
  late Process server;
  late StreamSubscription<String> stdoutSub;
  int msgId = 0;

  final completers = <Completer<String>>[];

  Future<Map<String, dynamic>> sendRequest(
      String method, Map<String, dynamic> params) async {
    msgId++;
    final completer = Completer<String>();
    completers.add(completer);

    final request = jsonEncode({
      'jsonrpc': '2.0',
      'id': msgId,
      'method': method,
      'params': params,
    });
    server.stdin.writeln(request);
    final line = await completer.future.timeout(const Duration(seconds: 30));
    return jsonDecode(line) as Map<String, dynamic>;
  }

  Map<String, dynamic> extractToolResult(Map<String, dynamic> response) {
    if (response.containsKey('error')) {
      return {'ok': false, 'error': response['error']};
    }
    final result = response['result'] as Map<String, dynamic>;
    final content = result['content'] as List<dynamic>;
    final text = content[0] as Map<String, dynamic>;
    final textStr = text['text'] as String;

    try {
      return jsonDecode(textStr) as Map<String, dynamic>;
    } catch (_) {
      return {
        'ok': false,
        'error': {'code': 'TOOL_ERROR', 'message': textStr}
      };
    }
  }

  setUp(() {
    msgId = 0;
    completers.clear();
  });

  setUpAll(() async {
    cacheDir = Directory('.e2e_cache');
    if (cacheDir.existsSync()) cacheDir.deleteSync(recursive: true);
    cacheDir.createSync();

    final localDocsUrl = Platform.environment['LOCAL_DOCS'];
    final serverArgs = [
      'bin/validasi_mcp.dart',
      '--cache-dir',
      cacheDir.path,
      '--refresh',
      if (localDocsUrl != null) '--base-url',
      if (localDocsUrl != null) localDocsUrl,
    ];

    server = await Process.start(
      Platform.resolvedExecutable,
      serverArgs,
    );

    stdoutSub = server.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        if (completers.isNotEmpty) {
          completers.removeAt(0).complete(line);
        }
      },
      onError: (e) => print('[stdout error] $e'),
    );

    server.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        if (line.isNotEmpty) print('[stderr] $line');
      },
    );

    await sendRequest('initialize', {
      'protocolVersion': '2024-11-05',
      'capabilities': {},
      'clientInfo': {'name': 'e2e-test', 'version': '1.0'},
    });

    server.stdin.writeln(jsonEncode({
      'jsonrpc': '2.0',
      'method': 'notifications/initialized',
    }));
  });

  tearDownAll(() async {
    await stdoutSub.cancel();
    server.kill();
    if (cacheDir.existsSync()) cacheDir.deleteSync(recursive: true);
  });

  Future<Map<String, dynamic>> callTool(
      String name, Map<String, dynamic> arguments) async {
    final response = await sendRequest('tools/call', {
      'name': name,
      'arguments': arguments,
    });
    return extractToolResult(response);
  }

  group('MCP tools produce valid response shapes', () {
    test('search_docs', () async {
      final result = await callTool('search_docs', {'query': 'StringRules'});

      expect(result, containsPair('ok', isA<bool>()));

      // Results is always a list (may be empty)
      expect(result, containsPair('results', isA<List>()));
    });

    test('get_page (existing)', () async {
      final result =
          await callTool('get_page', {'path': 'guide/getting-started'});

      expect(result, containsPair('ok', isTrue));
      expect(result, containsPair('page', isA<Map>()));

      final page = result['page'] as Map<String, dynamic>;
      expect(page, containsPair('path', 'guide/getting-started'));
      expect(page, containsPair('title', isA<String>()));
      expect(page, containsPair('section', isA<String>()));
      expect(page, containsPair('content', isA<String>()));
      expect(page['content'].length, greaterThan(0));
      expect(page, containsPair('headings', isA<List>()));

      final headings = page['headings'] as List;
      expect(headings, isNotEmpty);
      for (final h in headings) {
        expect(h, isA<Map>());
        expect(h, containsPair('level', isA<int>()));
        expect(h, containsPair('text', isA<String>()));
      }
    });

    test('get_page (not found)', () async {
      final result = await callTool('get_page', {'path': 'nonexistent'});

      expect(result, containsPair('ok', isFalse));
      expect(result, containsPair('error', isA<Map>()));

      final error = result['error'] as Map<String, dynamic>;
      expect(error, containsPair('code', 'NOT_FOUND'));
      expect(error, containsPair('message', isA<String>()));
    });

    test('list_pages (all)', () async {
      final result = await callTool('list_pages', {});

      expect(result, containsPair('ok', isTrue));
      expect(result, containsPair('sections', isA<List>()));

      final sections = result['sections'] as List;
      expect(sections, isNotEmpty);

      for (final section in sections) {
        expect(section, containsPair('name', isA<String>()));
        expect(section, containsPair('pages', isA<List>()));
        for (final page in section['pages']) {
          expect(page, containsPair('path', isA<String>()));
          expect(page, containsPair('title', isA<String>()));
        }
      }

      // Verify known sections exist
      final sectionNames = sections.map((s) => s['name'] as String).toSet();
      expect(sectionNames, contains('guide'));
      expect(sectionNames, contains('schemas'));
      expect(sectionNames, contains('advanced'));
    });

    test('list_pages (filtered)', () async {
      final result = await callTool('list_pages', {'section': 'schemas'});

      expect(result, containsPair('ok', isTrue));
      expect(result, containsPair('sections', isA<List>()));

      final sections = result['sections'] as List;
      expect(sections, hasLength(1));
      expect(sections[0]['name'], equals('schemas'));

      final pages = sections[0]['pages'] as List;
      expect(pages, isNotEmpty);
      for (final page in pages) {
        expect(page['path'], startsWith('schemas/'));
      }
    });

    test('get_code_examples', () async {
      final result = await callTool('get_code_examples', {});

      expect(result, containsPair('ok', isTrue));
      expect(result, containsPair('count', isA<int>()));
      expect(result, containsPair('examples', isA<List>()));

      final examples = result['examples'] as List;
      expect(examples, isNotEmpty);
      expect(result['count'], equals(examples.length));

      for (final example in examples) {
        expect(example, containsPair('language', isA<String>()));
        expect(example, containsPair('code', isA<String>()));
        expect(example['code'].length, greaterThan(0));
      }
    });

    test('get_code_examples (filtered by rule)', () async {
      final result = await callTool('get_code_examples', {'rule': 'minLength'});

      expect(result, containsPair('ok', isTrue));
      expect(result, containsPair('count', isA<int>()));
      expect(result, containsPair('examples', isA<List>()));

      final examples = result['examples'] as List;
      expect(result['count'], equals(examples.length));

      // Each example's code should contain "minLength" somewhere
      for (final example in examples) {
        expect(example, containsPair('language', isA<String>()));
        expect(example, containsPair('code', isA<String>()));
        expect(example['code'], contains('minLength'));
      }
    });

    test('unknown tool', () async {
      final result = await callTool('unknown_tool', {});

      expect(result, containsPair('ok', isFalse));
      expect(result, containsPair('error', isA<Map>()));

      final error = result['error'] as Map<String, dynamic>;
      expect(error, containsPair('code', 'TOOL_ERROR'));
      expect(error, containsPair('message', isA<String>()));
    });
  });

  group('MCP server capabilities', () {
    test('tools/list returns 6 tools with expected names', () async {
      final response = await sendRequest('tools/list', {});
      final result = response['result'] as Map<String, dynamic>;
      final tools = result['tools'] as List<dynamic>;
      expect(tools, hasLength(6));

      for (final tool in tools) {
        expect(tool, containsPair('name', isA<String>()));
        expect(tool, containsPair('description', isA<String>()));
        expect(tool, containsPair('inputSchema', isA<Map>()));
      }

      final names = tools.map((t) => t['name'] as String).toSet();
      expect(
          names,
          containsAll([
            'search_docs',
            'get_page',
            'list_pages',
            'get_code_examples',
            'refresh_docs',
            'clean_cache',
          ]));
    });
  });
}
