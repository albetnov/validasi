# Built-in Modifier Rules

This page covers the modifier rules that apply across schemas. Type-specific rules are documented separately.

## Global Rules

### Nullable

Allows `null` values to pass validation.

```dart
final optionalNameSchema = Validasi.string([
  Nullable(),
  StringRules.minLength(3),
]);

print(optionalNameSchema.validate(null).isValid);
print(optionalNameSchema.validate('John').isValid);
```

### Required

Explicitly requires a non-null value.

```dart
final requiredNameSchema = Validasi.string([
  Required(),
  StringRules.minLength(3),
]);

print(requiredNameSchema.validate(null).isValid);
```

### Transform

Changes the value before later rules run.

```dart
final trimmedSchema = Validasi.string([
  Transform((value) => value?.trim()),
  StringRules.minLength(3),
]);

final result = trimmedSchema.validate('  hello  ');
print(result.data);
print(result.isValid);
```

### Having

Ensures the value is one of a set of allowed values.

```dart
final schema = Validasi.string([
  Having(['draft', 'published', 'archived']),
]);
```

### InlineRule

Runs custom validation inline without using context.

```dart
final passwordSchema = Validasi.string([
  StringRules.minLength(8),
  InlineRule<String>((value) {
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
  Nullable(),
  Transform((value) => value?.trim()),
  Transform((value) => value?.toLowerCase()),
  InlineRule<String>((value) {
    if (value != null && value.length < 3) {
      return 'Too short';
    }
    return null;
  }),
  StringRules.maxLength(50),
]);
```

### Choosing the Right Rule

- Use `Nullable()` when `null` is allowed.
- Use `Required()` when you want to make non-null intent explicit.
- Use `Transform()` for normalization or data cleanup.
- Use `Having()` when the rule needs validation context.
- Use `InlineRule()` for simple custom validation.

## Best Practices

- Put `Nullable()` or `Required()` first so the schema intent is obvious.
- Keep `Transform()` rules before validation rules.
- Use the simplest rule that fits the job.
- Keep error messages short and clear.
