# Best Practices

Idiomatic, documentation-backed patterns for writing maintainable `validasi` code. The SKILL.md has
the short list of highest-value habits; this is the full set with the reasoning behind each.

All examples assume both imports:

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi/rules.dart';
```

## 1. Keep schemas small and reusable

Break large schemas into named rule lists and sub-schemas, then compose them. Each unit stays focused
and testable, and rules get reused across schemas.

```dart
final emailRules = <Rule<String>>[
  Rules.transform<String>((value) => value?.trim().toLowerCase()),
  Rules.string.minLength(5),
  Rules.string.email(),
];

final passwordRules = <Rule<String>>[Rules.string.minLength(8)];

final registrationSchema = Validasi.map<dynamic>([
  Rules.map.hasFields({
    'email': FieldRules<String>(emailRules),
    'password': FieldRules<String>(passwordRules),
    'confirmPassword': FieldRules<String>(passwordRules),
  }),
  Rules.map.matchesField('password', 'confirmPassword'),
]);
```

## 2. Use explicit type parameters

Specify the generic — it keeps input/output types precise and turns mistakes into compile errors.
Prefer `Rules.nullable<String>()` over `Rules.nullable()`, and `Validasi.number<int>` over
`Validasi.number`.

## 3. Order rules deliberately

The loop feeds each rule's output to the next, so order is behavior, not style. A good default:

1. Nullability intent — `Rules.nullable<T>()` / `Rules.required<T>()` first
2. Normalizing transforms — `Rules.transform<T>()`
3. Validation rules — length, range, format
4. Cross-field / composite checks

```dart
final usernameSchema = Validasi.string([
  Rules.nullable<String>(),
  Rules.transform<String>((value) => value?.trim().toLowerCase()),
  Rules.string.minLength(3),
  Rules.string.maxLength(20),
  Rules.string.alphanumeric(),
]);
```

## 4. Transform before validating

Put `Transform` rules ahead of validation rules that depend on the normalized value — otherwise the
check runs against raw input (e.g. `minLength` counting leading/trailing spaces).

## 5. Choose the right tool: transform vs. preprocess

| Goal | Use |
|------|-----|
| Normalize a value already of the correct type | `Rules.transform<T>()` |
| Parse/convert raw input into the schema type | `withPreprocess(...)` |
| Accept dynamic input safely | `withPreprocess` with an explicit input type (preferred) |

`withPreprocess` enforces the input type at compile time, so wrong-typed calls fail to compile. See
`engine.md`.

## 6. Keep transformations pure

A transform should take a value and return a value — no side effects (no logging, analytics, or I/O).
Pure transforms are predictable and safe to reorder or reuse.

## 7. Make transforms null-safe under nullable schemas

`Transform` runs on `null` too, and under `Rules.nullable<T>()` it will receive null. Handle it:

```dart
Validasi.string([
  Rules.nullable<String>(),
  Rules.transform<String>((value) => value?.trim()), // null-safe
  Rules.string.minLength(3),
]);
```

## 8. Type-annotate preprocess functions

`.withPreprocess((String value) => int.parse(value))` — the explicit parameter type gives compile-time
safety and states intent, versus an inferred `dynamic`.

## 9. Prefer built-in rules over inline

A built-in rule is tested, clearer, and usually produces better messages. Use `Rules.inline<T>()`
only for one-off checks with no built-in equivalent.

```dart
Rules.string.email();                                  // good
Rules.inline<String>((v) => v!.contains('@') ? true : false); // avoid when a built-in exists
```

## 10. Write clear, user-friendly messages

Default messages should be actionable; custom messages should say what to do. For custom rules, always
provide a default and allow an override:

```dart
Rules.string.minLength(3, message: 'Username must be at least 3 characters');
```

## 11. Separate user messages from diagnostics

`message` is for end users; `path` is for field mapping; `rule` and `details` are for logs and
programmatic handling. Return the full `errors` list from inner layers and format at the boundary:

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

## 12. Branch on `result.isValid` first

`data` is only meaningful when valid — check `isValid` before using it.

```dart
final result = schema.validate(input);
if (result.isValid) {
  persist(result.data);
} else {
  showErrors(result.errors);
}
```

## 13. Use `error.path` as the source of truth

For nested maps and lists, `path` tells you exactly where a failure occurred (container rules like
`hasFields`/`forEach` set it for you).

```dart
for (final error in result.errors) {
  final field = error.path?.join('.') ?? 'root';
  print('[$field] ${error.message}');
}
```

## 14. Prefer `withPreprocess` over a raw dynamic engine

When the input shape is known, `withPreprocess` gives both type safety and conversion. Reserve the
direct `ValidasiEngine<T, dynamic>` form for truly dynamic callers — and note it needs
`import 'package:validasi/engine.dart'` and a **named** `rules:` argument:

```dart
// Preferred
Validasi.number<int>([Rules.number.moreThan(0)]).withPreprocess((String s) => int.parse(s));

// Reserve for dynamic callers
import 'package:validasi/engine.dart';
ValidasiEngine<int, dynamic>(rules: [Rules.number.moreThan(0)]);
```

## 15. Use `Validasi.any<T>()` for escape hatches

Use `any` when the type isn't covered by a specialized builder, for custom domain models, or for maps
with non-`String` keys.

```dart
final intKeyMap = Validasi.any<Map<int, String>>([
  Rules.inline<Map<int, String>>(
    (value) => value != null && value.containsKey(1),
    message: 'Map must contain key 1',
  ),
]);
```

## 16. Mind performance with `unique`

With custom equality, provide `hasher` alongside `equals` for O(N); `equals` alone falls back to O(N²).

```dart
Rules.iterable.unique(
  equals: (a, b) => a['id'] == b['id'],
  hasher: (m) => m['id']?.hashCode ?? 0,
);
```

## 17. Promote repeated inline checks to a `Rule<T>` class

When the same check appears in several places, make it a class — reusable, testable, and able to carry
`details` or stop the chain. See `custom-rules.md`.

## 18. Always use `validateAsync()` for async rules

If the pipeline has any `AsyncRule`, `Rules.inlineAsync`, or `Rules.transformAsync`, call
`validateAsync()` — `validate()` throws a `StateError`.

## 19. Set `runOnNull` only when necessary

The default `false` is right for most rules. Override `runOnNull => true` only when the rule must see
null (require it, transform it, or default it).

## 20. Keep map schemas strict when shape matters

Combine `allowedKeys` (reject unexpected keys) with `hasFieldKeys`/`hasFields` (enforce required
shape):

```dart
final strictUser = Validasi.map<dynamic>([
  Rules.map.hasFieldKeys({'name', 'email'}),
  Rules.map.hasFields({
    'name': FieldRules<String>([Rules.string.minLength(2)]),
    'email': FieldRules<String>([Rules.string.email()]),
  }),
  Rules.map.allowedKeys({'name', 'email'}),
]);
```

## Anti-patterns to avoid

| Anti-pattern | Why it hurts | Better |
|--------------|--------------|--------|
| Hand-rolled regex for email | reinvents a tested rule, worse messages | `Rules.string.email()` |
| Transform after validation | validation sees untransformed data | put transforms first |
| `validate()` with async rules | throws `StateError` | `validateAsync()` |
| Raw errors as user text | leaks `rule` names / internals | format `message` for users, keep `rule`/`details` for logs |
| `equals` without `hasher` in `unique` | O(N²) | provide both `equals` and `hasher` |
| Letting generics infer to `dynamic` | loses compile-time safety | pass explicit type parameters |
| Positional `ValidasiEngine<...>([...])` | constructor takes a named `rules:` | `ValidasiEngine<T, In>(rules: [...])` |
| `import validasi.dart` alone for custom rules | `Rule`/`ValidationState` aren't exported there | also import `rules.dart` |
