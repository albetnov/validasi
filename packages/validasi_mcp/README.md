# validasi_mcp

MCP stdio adapter for Validasi schemas.

> Beta: this adapter currently supports Validasi `v1.0.0-dev.x` only.

## Features

- Register named schemas through a `SchemaRegistry`
- Expose MCP tools:
  - `list_schemas`
  - `describe_schema`
  - `validate_input`
- Return deterministic structured validation payloads from Validasi

## Quick start

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';
import 'package:validasi_mcp/validasi_mcp.dart';

final registry = SchemaRegistry()
  ..register(
    id: 'username',
    description: 'username must be at least 3 chars',
    builder: () => Validasi.string([
      StringRules.minLength(3),
    ]),
  );

final handlers = ValidasiMcpToolHandlers(registry: registry);
final server = ValidasiMcpStdioServer(handlers: handlers);
await server.serve();
```

## Run server

```bash
dart run bin/validasi_mcp.dart
```

The process uses JSON-RPC over stdio and supports MCP `initialize`, `tools/list`, and `tools/call`.
