# Agent-Native Support

::: warning Beta Status
Agent-native support is currently in beta and only supports Validasi `v1.0.0-dev.x`.
:::

Use Validasi as a stable validation backend for AI tools and automation.

This page covers core APIs:
- `ValidasiEngine.introspect()` for machine-readable schema metadata
- `ValidasiResult.toToolResponse()` for deterministic validation outputs
- `ValidationError.toToolMap()` for deterministic error entries

## Why this matters

Tool-calling systems work best with predictable payloads. Agent-native support helps you:
- describe validation contracts before executing
- return stable error structures for retries and remediation
- make nested failures traceable with path-based diagnostics

## 1) Export schema metadata

```dart
import 'dart:convert';
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';

final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields({
    'name': FieldRules<String>([
      StringRules.minLength(2),
      StringRules.maxLength(50),
    ]),
    'age': FieldRules<int>([
      NumberRules.moreThanEqual(18),
    ]),
  }),
]);

final descriptor = userSchema.introspect().toJson();
print(jsonEncode(descriptor));
```

The descriptor includes:
- schema id and value type
- preprocess flag
- ordered rule metadata
- field names from `HasFields` via parameters

## 2) Return deterministic tool payloads

```dart
import 'dart:convert';

final result = userSchema.validate({
  'name': 'A',
  'age': 15,
});

final payload = result.toToolResponse();
print(jsonEncode(payload));
```

Example payload shape:

```json
{
  "isValid": false,
  "data": null,
  "errorCount": 2,
  "errors": [
    {
      "rule": "MinLength",
      "message": "Minimum length is 2 characters",
      "path": ["name"],
      "details": {"length": "2"}
    },
    {
      "rule": "MoreThanEqual",
      "message": "value must be more than or equal to 18",
      "path": ["age"]
    }
  ]
}
```

## 3) Use error entries directly

```dart
for (final error in result.errors) {
  final toolError = error.toToolMap();
  // forward to logger, agent memory, or retry planner
  print(toolError);
}
```

## Dynamic rules

Callback-driven rules such as `InlineRule`, `Transform`, and `ConditionalField` are marked as dynamic in metadata because callback logic is not introspectable.

## 4) Use the MCP adapter (Beta)

The repository now includes a beta adapter package at `packages/validasi_mcp`.

It provides:
- `SchemaRegistry` to register named schemas
- `ValidasiMcpToolHandlers` for tool dispatch
- `ValidasiMcpStdioServer` for JSON-RPC stdio transport

Supported MCP methods:
- `initialize`
- `tools/list`
- `tools/call`

Supported tools:
- `list_schemas`
- `describe_schema`
- `validate_input`

Start the server:

```bash
cd packages/validasi_mcp
dart run bin/validasi_mcp.dart
```

Example MCP request (`tools/call`):

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "validate_input",
    "arguments": {
      "schema_id": "user.name",
      "input": "A"
    }
  }
}
```

The response includes both text content and `structuredContent` for direct machine consumption.
