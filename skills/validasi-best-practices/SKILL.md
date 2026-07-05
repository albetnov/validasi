---
name: validasi-best-practices
description: Best practices and idiomatic patterns for using the validasi core validation library. Use when the user asks how to structure schemas, write maintainable validation code, avoid common mistakes, or optimize validasi usage.
---

# Validasi Best Practices

This skill collects opinionated, documentation-backed best practices for the core `validasi` package.

## When to Use This Skill

Use this skill when the user:

- Asks for best practices, dos and don'ts, or style guidance for validasi
- Wants to structure schemas in a maintainable way
- Asks how to order rules, handle errors, or choose between rules
- Needs guidance on transformations, preprocessing, or type safety
- Wants to avoid common mistakes or performance pitfalls

## 1. Keep Schemas Small and Reusable

Break large schemas into small, named rule lists and sub-schemas. Compose them into larger schemas with `Rules.map`, `Rules.iterable`, or additional rules.

**Good:**

```dart
final emailRules = <Rule<String>>[
  Rules.transform<String>((value) => value?.trim().toLowerCase()),
  Rules.string.minLength(5),
  Rules.string.email(),
];

final passwordRules = <Rule<String>>[
  Rules.string.minLength(8),
];

final registrationSchema = Validasi.map<dynamic>([
  Rules.map.hasFields({
    'email': FieldRules<String>(emailRules),
    'password': FieldRules<String>(passwordRules),
    'confirmPassword': FieldRules<String>(passwordRules),
  }),
  Rules.inline<Map<String, dynamic>>((value) {
    return value['password'] == value['confirmPassword']
        ? null
        : 'Passwords do not match';
  }),
]);
```

This keeps each unit focused and testable, and lets you reuse rules across schemas.

## 2. Use Explicit Type Parameters

Always specify the generic type parameter for better type safety and clearer intent.

**Good:**

```dart
final ageSchema = Validasi.number<int>([
  Rules.number.moreThanEqual(0),
]);
```

**Avoid:**

```dart
final ageSchema = Validasi.number([ // type may be inferred or dynamic
  Rules.number.moreThanEqual(0),
]);
```

This applies to modifier rules too: prefer `Rules.nullable<String>()` over `Rules.nullable()`.

## 3. Order Rules Deliberately

Place rules in this general order:

1. **Nullability intent** — `Rules.nullable<T>()` or `Rules.required<T>()` first
2. **Preprocessing transforms** — `Rules.transform<T>()` before validation
3. **Validation rules** — length, range, format, etc.
4. **Cross-field or composite checks** — `Rules.inline<T>()` that depend on earlier normalization

**Good:**

```dart
final usernameSchema = Validasi.string([
  Rules.nullable<String>(),
  Rules.transform<String>((value) => value?.trim().toLowerCase()),
  Rules.string.minLength(3),
  Rules.string.maxLength(20),
  Rules.string.alphanumeric(),
]);
```

## 4. Transform Before Validating

Put `Transform` rules before validation rules that depend on normalized values. The rule loop passes each transformed value to the next rule.

**Good:**

```dart
Validasi.string([
  Rules.transform<String>((value) => value?.trim()),
  Rules.string.minLength(3),
])
```

**Avoid:**

```dart
Validasi.string([
  Rules.string.minLength(3),
  Rules.transform<String>((value) => value?.trim()),
])
```

In the second example, the length check runs on untrimmed input.

## 5. Choose the Right Tool: Transform vs Preprocess

| Goal | Use |
|------|-----|
| Normalize a value that is already the correct type | `Rules.transform<T>()` |
| Parse/convert raw input into the schema type | `withPreprocess(...)` |
| Accept dynamic input safely | `withPreprocess` with explicit input type (preferred) or `ValidasiEngine<T, dynamic>` |

**Good:**

```dart
final ageSchema = Validasi.number<int>([
  Rules.number.moreThanEqual(0),
]).withPreprocess((String value) => int.parse(value));
```

`withPreprocess` also enforces the input type at compile time, so `ageSchema.validate(25)` becomes a compile error.

## 6. Keep Transformations Pure

Transformations should not have side effects. They should take a value and return a transformed value.

**Good:**

```dart
Rules.transform<String>((value) => value?.trim().toLowerCase())
```

**Avoid:**

```dart
Rules.transform<String>((value) {
  analytics.track('normalized'); // side effect
  return value?.trim();
})
```

## 7. Make Transforms Null-Safe with Nullable Schemas

When using `Rules.nullable<T>()`, transforms may receive `null`. Handle it gracefully.

```dart
Validasi.string([
  Rules.nullable<String>(),
  Rules.transform<String>((value) => value?.trim()), // null-safe
  Rules.string.minLength(3),
])
```

## 8. Type-Annotate Preprocess Functions

Explicit parameter types give you compile-time safety and clearer intent.

**Good:**

```dart
.withPreprocess((String value) => int.parse(value))
```

**Avoid:**

```dart
.withPreprocess((value) => int.parse(value)) // inferred as dynamic
```

## 9. Use Built-In Rules Before Inline Rules

Prefer a built-in rule when one exists. It is clearer, tested, and often produces better error messages.

**Good:**

```dart
Rules.string.email()
```

**Avoid:**

```dart
Rules.inline<String>((value) =>
  value.contains('@') ? null : 'Invalid email')
```

Use `Rules.inline<T>()` only for one-off checks that have no built-in equivalent.

## 10. Write Clear, User-Friendly Error Messages

Default messages should be actionable. Custom messages should describe what the user should do.

**Good:**

```dart
Rules.string.minLength(3, message: 'Username must be at least 3 characters')
```

For custom rules, always provide a default and allow override:

```dart
state.addError(
  ValidationError(
    rule: 'MinAge',
    message: message ?? 'Age must be at least $minAge',
    details: {'minAge': minAge.toString()},
  ),
);
```

## 11. Separate User Messages from Diagnostics

- `message` is for end users
- `path` is for field-level mapping in UI
- `rule` and `details` are for logs, diagnostics, and programmatic handling

Return the full `errors` list from internal layers, then format at the boundary (UI or API):

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

## 12. Branch on `result.isValid` First

Always check validity before using `result.data`.

**Good:**

```dart
final result = schema.validate(input);

if (result.isValid) {
  persist(result.data);
} else {
  showErrors(result.errors);
}
```

## 13. Use `error.path` as the Source of Truth

For nested maps and lists, `path` tells you exactly where the error occurred.

```dart
for (final error in result.errors) {
  final field = error.path?.join('.') ?? 'root';
  print('[$field] ${error.message}');
}
```

## 14. Prefer `withPreprocess` Over `ValidasiEngine<T, dynamic>`

When the input shape is known, `withPreprocess` gives you both type safety and runtime conversion.

**Good:**

```dart
Validasi.number<int>([...]).withPreprocess((String s) => int.parse(s))
```

**Reserve for truly dynamic cases:**

```dart
ValidasiEngine<int, dynamic>([
  Rules.number.moreThan(0),
])
```

## 15. Use `Validasi.any<T>()` for Escape Hatches

Use `Validasi.any<T>()` when:

- The type is not covered by specialized builders
- You need custom domain-model validation
- You are validating maps with non-`String` keys

```dart
final intKeyMapSchema = Validasi.any<Map<int, String>>([
  Rules.inline<Map<int, String>>(
    (value) => value != null && value.containsKey(1),
    message: 'Map must contain key 1',
  ),
]);
```

## 16. Mind Performance with `unique`

When using `Rules.iterable.unique()` with custom equality, provide `hasher` alongside `equals` for O(N) performance.

**Good:**

```dart
Rules.iterable.unique(
  equals: (a, b) => a['id'] == b['id'],
  hasher: (m) => m['id']?.hashCode ?? 0,
)
```

`equals` without `hasher` falls back to O(N²) comparisons.

## 17. Use Custom Rule Classes for Reusable Logic

When the same inline check appears in multiple places, promote it to a `Rule<T>` class.

**Good:**

```dart
class UrlRule extends Rule<String> {
  const UrlRule({super.message});

  @override
  String? apply(String? value, ValidationState state) {
    if (value == null) return null;
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      state.addError(
        ValidationError(
          rule: 'Url',
          message: message ?? 'URL must start with http:// or https://',
        ),
      );
    }
    return value;
  }
}
```

## 18. Always Use `validateAsync()` for Async Rules

If a pipeline contains any `AsyncRule`, `inlineAsync`, or `transformAsync`, call `validateAsync()`. Calling `validate()` throws `StateError`.

**Good:**

```dart
final result = await schema.validateAsync('user@example.com');
```

## 19. Set `runOnNull` Only When Necessary

The default `runOnNull = false` is correct for most rules. Override it only when the rule must handle `null` (validation, default values, or null transformation).

```dart
class DefaultValue<T> extends Rule<T> {
  const DefaultValue(this.defaultValue, {super.message});

  final T defaultValue;

  @override
  bool get runOnNull => true;

  @override
  T? apply(T? value, ValidationState state) {
    return value ?? defaultValue;
  }
}
```

## 20. Keep Map Schemas Strict

Use `Rules.map.allowedKeys()` when you want to reject unexpected keys. Combine with `hasFieldKeys` or `hasFields` for shape enforcement.

```dart
final strictUserSchema = Validasi.map<dynamic>([
  Rules.map.hasFieldKeys({'name', 'email'}),
  Rules.map.hasFields({
    'name': FieldRules<String>([Rules.string.minLength(2)]),
    'email': FieldRules<String>([Rules.string.email()]),
  }),
  Rules.map.allowedKeys({'name', 'email'}),
]);
```

## Anti-Patterns to Avoid

| Anti-Pattern | Why | Better Alternative |
|--------------|-----|-------------------|
| Manual regex for email | Built-in rule is tested and clearer | `Rules.string.email()` |
| Transform after validation | Validation sees untransformed data | Put transform before validation |
| `validate()` with async rules | Throws `StateError` | Use `validateAsync()` |
| Returning raw errors as user text | Leaks internal rule names | Format `message` for users, `rule`/`details` for logs |
| `equals` without `hasher` in `unique` | O(N²) performance | Provide both `equals` and `hasher` |
| Letting generics infer to `dynamic` | Loses compile-time safety | Specify explicit type parameters |

See `validasi-guide` for detailed API usage and examples.
