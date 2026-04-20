# Error Handling

This guide focuses on using `ValidasiResult<T>` effectively when validation fails.

## What You Get from ValidasiResult

Every validation returns:

- `isValid`: validation status
- `data`: validated/transformed value (when valid)
- `errors`: list of `ValidationError`

Each `ValidationError` contains:

- `rule`: rule name that produced the error
- `message`: human-readable error message
- `path`: field path for nested values
- `details`: optional debug metadata

## Basic Error Flow

```dart
final result = schema.validate(input);

if (result.isValid) {
  useValidatedData(result.data);
  return;
}

for (final error in result.errors) {
  final path = error.path?.join('.') ?? 'root';
  print('[$path] ${error.message} (${error.rule})');
}
```

Use this as your default pattern:

1. Check `isValid`.
2. On failure, iterate `errors`.
3. Use `path` for field mapping and `rule`/`details` for debugging.

## Full Use of ValidationError Fields

```dart
for (final error in result.errors) {
  final field = error.path?.join('.') ?? 'root';
  final rule = error.rule;
  final message = error.message;
  final debug = error.details;

  print('field=$field rule=$rule message=$message details=$debug');
}
```

- `message` is for user feedback.
- `path` is for attaching errors to inputs.
- `rule` and `details` are for logs and diagnostics.

## Convert Errors for UI

```dart
Map<String, List<String>> errorsByField<T>(ValidasiResult<T> result) {
  final grouped = <String, List<String>>{};

  for (final error in result.errors) {
    final field = error.path?.join('.') ?? 'root';
    grouped.putIfAbsent(field, () => []).add(error.message);
  }

  return grouped;
}
```

This makes it easy to show per-field errors in forms.

## Convert Errors for API Responses

```dart
List<Map<String, dynamic>> errorsToJson<T>(ValidasiResult<T> result) {
  return result.errors
      .map((error) => {
            'field': error.path?.join('.'),
            'rule': error.rule,
            'message': error.message,
            'details': error.details,
          })
      .toList();
}
```

## Throwing Validation Errors

```dart
class ValidationException implements Exception {
  ValidationException(this.errors);

  final List<ValidationError> errors;

  @override
  String toString() {
    return errors
        .map((e) => '[${e.path?.join('.') ?? 'root'}] ${e.message}')
        .join(', ');
  }
}

void save(dynamic payload) {
  final result = schema.validate(payload);
  if (!result.isValid) {
    throw ValidationException(result.errors);
  }

  persist(result.data);
}
```

## Best Practices

- Always branch on `result.isValid` first.
- Use `error.path` as the source of truth for field-level mapping.
- Keep user messages in `message`; keep diagnostics in logs with `rule` and `details`.
- Return full `errors` in internal layers, then format at the boundary (UI/API).
