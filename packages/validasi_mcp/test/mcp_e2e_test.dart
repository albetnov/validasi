import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

const _snapshotDir = 'test/snapshots';

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

    server = await Process.start(
      Platform.resolvedExecutable,
      ['bin/validasi_mcp.dart', '--cache-dir', cacheDir.path, '--refresh'],
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

  group('MCP tools produce deterministic output', () {
    test('search_docs', () async {
      final result = await callTool('search_docs', {'query': 'StringRules'});
      _compareToSnapshot('search_docs', result);
    });

    test('get_page (existing)', () async {
      final result =
          await callTool('get_page', {'path': 'guide/getting-started'});
      _compareToSnapshot('get_page', result);
    });

    test('get_page (not found)', () async {
      final result = await callTool('get_page', {'path': 'nonexistent'});
      _compareToSnapshot('get_page_not_found', result);
    });

    test('list_pages (all)', () async {
      final result = await callTool('list_pages', {});
      _compareToSnapshot('list_pages', result);
    });

    test('list_pages (filtered)', () async {
      final result = await callTool('list_pages', {'section': 'schemas'});
      _compareToSnapshot('list_pages_filtered', result);
    });

    test('get_code_examples', () async {
      final result = await callTool('get_code_examples', {});
      _compareToSnapshot('get_code_examples', result);
    });

    test('get_code_examples (filtered by rule)', () async {
      final result = await callTool('get_code_examples', {'rule': 'minLength'});
      _compareToSnapshot('get_code_examples_filtered', result);
    });

    test('unknown tool', () async {
      final result = await callTool('unknown_tool', {});
      _compareToSnapshot('unknown_tool', result);
    });
  });

  group('MCP server capabilities', () {
    test('tools/list returns 6 tools', () async {
      final response = await sendRequest('tools/list', {});
      final result = response['result'] as Map<String, dynamic>;
      final tools = result['tools'] as List<dynamic>;
      expect(tools, hasLength(6));
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

String _snapshotPath(String name) => '$_snapshotDir/$name.json';

void _compareToSnapshot(String name, Map<String, dynamic> actual) {
  final path = _snapshotPath(name);
  final snapshotFile = File(path);

  if (Platform.environment['UPDATE_SNAPSHOTS'] == 'true') {
    snapshotFile.parent.createSync(recursive: true);
    snapshotFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(actual),
    );
    print('  → wrote snapshot: $path');
    return;
  }

  if (!snapshotFile.existsSync()) {
    fail(
      'No snapshot found at $path.\n'
      'Run with UPDATE_SNAPSHOTS=true to generate it.\n'
      'Actual result:\n'
      '${const JsonEncoder.withIndent('  ').convert(actual)}',
    );
  }

  final expectedJson = snapshotFile.readAsStringSync();
  final expected = jsonDecode(expectedJson) as Map<String, dynamic>;
  expect(actual, equals(expected));
}
