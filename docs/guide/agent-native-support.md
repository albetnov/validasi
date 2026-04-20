# Agent-Native Support

Use Validasi as a stable validation backend for AI tools and automation.

This page covers the Wave 2 core APIs:
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
import 'package:validasi/engine.dart';

final userFields = <String, ValidasiEngine<dynamic>>{
  'name': Validasi.string([
      StringRules.minLength(2),
      StringRules.maxLength(50),
    ]),
  'age': Validasi.number<int>([
      NumberRules.moreThanEqual(18),
    ]),
};

final userSchema = Validasi.map<dynamic>([
  MapRules.hasFields<dynamic>(userFields),
]);

final descriptor = userSchema.introspect().toJson();
print(jsonEncode(descriptor));
```

The descriptor includes:
- schema id and value type
- cache/preprocess flags
- ordered rule metadata
- nested schema metadata for composition rules such as `ForEach` and `HasFields`

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

## Next step

Wave 3 adds an MCP adapter package so external MCP clients can invoke Validasi directly over stdio.
