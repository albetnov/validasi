# Built-in Modifier Rules

This page covers the modifier rules that apply across schemas. Type-specific rules are documented separately.

## Global Rules

### Nullable

Allows `null` values to pass validation.

```dart
final optionalNameSchema = Validasi.string([
  Rules.nullable<String>(),
  Rules.string.minLength(3),
]);

print(optionalNameSchema.validate(null).isValid);
print(optionalNameSchema.validate('John').isValid);
```

### Required

Explicitly requires a non-null value.

```dart
final requiredNameSchema = Validasi.string([
  Rules.required<String>(),
  Rules.string.minLength(3),
]);

print(requiredNameSchema.validate(null).isValid);
```

### Transform

Changes the value before later rules run.

```dart
final trimmedSchema = Validasi.string([
  Rules.transform<String>((value) => value?.trim()),
  Rules.string.minLength(3),
]);

final result = trimmedSchema.validate('  hello  ');
print(result.data);
print(result.isValid);
```

### Having

Ensures the value is one of a set of allowed values.

```dart
final schema = Validasi.string([
  Rules.having<String>(['draft', 'published', 'archived']),
]);
```

### InlineRule

Runs custom validation inline without using context.

```dart
final passwordSchema = Validasi.string([
  Rules.string.minLength(8),
  Rules.inline<String>((value) {
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain at least one uppercase letter';
    }
    return null;
  }),
]);
```

## Special Rules

These rules are still modifier rules, but they are used for more advanced control over validation behavior.

### Combining Rules

You can stack modifier rules to clean, normalize, and validate in one schema.

```dart
final schema = Validasi.string([
  Rules.nullable<String>(),
  Rules.transform<String>((value) => value?.trim()),
  Rules.transform<String>((value) => value?.toLowerCase()),
  Rules.inline<String>((value) {
    if (value != null && value.length < 3) {
      return 'Too short';
    }
    return null;
  }),
  Rules.string.maxLength(50),
]);
```

### Choosing the Right Rule

- Use `Rules.nullable<String>()` when `null` is allowed.
- Use `Rules.required<String>()` when you want to make non-null intent explicit.
- Use `Rules.transform<String>()` for normalization or data cleanup.
- Use `Rules.having<String>()` when the rule needs validation context.
- Use `Rules.inline<String>()` for simple custom validation.

## Best Practices

- Put `Rules.nullable<String>()` or `Rules.required<String>()` first so the schema intent is obvious.
- Keep `Rules.transform<String>()` rules before validation rules.
- Use the simplest rule that fits the job.
- Keep error messages short and clear.
