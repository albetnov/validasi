# Cross-field & Async Validation

Beyond per-field rules, `validasi_gen` supports cross-field validation (rules
spanning multiple fields) and async checks (database lookups, API calls).

## Cross-field: `@RefineFn`

`@RefineFn` annotates a method whose logic depends on multiple field values:

```dart
@ValidateClass()
class SignUpForm {
  @Validate<String>([Required(), MinLength(6)])
  final String password;

  @Validate<String>([Required()])
  final String confirmPassword;

  @RefineFn(dependsOn: ['password', 'confirmPassword'])
  void passwordsMatch(FailFn fail, {String? password, String? confirmPassword}) {
    if (password != null && confirmPassword != null && password != confirmPassword) {
      fail(message: 'Passwords do not match', path: ['confirmPassword']);
    }
  }

  const SignUpForm({required this.password, required this.confirmPassword});
}
```

### Rules

- The method's first parameter is always `FailFn`.
- Named parameters must match field names listed in `dependsOn`.
- Call `fail(message:, path:)` for each error. `path` targets the error at a specific field.
- The generator detects `Future<void>` returns and inserts `await` automatically.

### Multiple refines

A class can have any number of `@RefineFn` methods:

```dart
@ValidateClass()
class ContactForm {
  @Validate<String>([Required()]) final String email;
  @Validate<String>([Required()]) final String phone;

  @RefineFn(dependsOn: ['email', 'phone'])
  void atLeastOneContact(FailFn fail, {String? email, String? phone}) {
    if ((email == null || email.isEmpty) && (phone == null || phone.isEmpty)) {
      fail(message: 'Provide at least one contact method');
    }
  }

  @RefineFn(dependsOn: ['email'])
  void emailDomain(FailFn fail, {String? email}) {
    if (email != null && !email.endsWith('@company.com')) {
      fail(message: 'Must use company email');
    }
  }
}
```

## Async inline: `@AsyncInline`

For checks that require async work (database, API, file I/O), use `AsyncInline`:

```dart
Future<bool> _usernameAvailable(String? username) async {
  if (username == null) return false;
  final taken = await database.isTaken(username);
  return !taken;
}

@ValidateClass()
class User {
  @Validate<String>([Required(), MinLength(3), AsyncInline(_usernameAvailable)])
  final String username;

  const User({required this.username});
}
```

The function signature is `FutureOr<bool> Function(T?)`. Return `true` for valid,
`false` for invalid. Thrown exceptions are also treated as validation failures.

## Async custom rule: `AsyncCustomRule<T>`

For reusable async rules, subclass `AsyncCustomRule`:

```dart
class UniqueEmail extends AsyncCustomRule<String> {
  const UniqueEmail({String? message, super.runOnNull})
      : super(name: 'uniqueEmail', message: message);

  static Future<bool> check(String? value) async {
    if (value == null) return false;
    return !await database.emailExists(value);
  }
}

@ValidateClass()
class User {
  @Validate<String>([Required(), MinLength(5), UniqueEmail()])
  final String email;
}
```

## Custom rule: `@CustomRule`

For reusable sync rules, subclass `CustomRule`:

```dart
class NoSpaces extends CustomRule<String> {
  const NoSpaces({String? message, super.runOnNull})
      : super(name: 'noSpaces', message: message);

  static bool check(String? value) => value == null || !value.contains(' ');
}

@ValidateClass()
class User {
  @Validate<String>([Required(), NoSpaces()])
  final String username;
}
```

## Inline: `@Inline`

For quick one-off sync checks without creating a custom rule class:

```dart
bool _isEven(int? value) => value != null && value.isEven;

@ValidateClass()
class Item {
  @Validate<int>([Inline(_isEven, name: 'even')])
  final int quantity;

  const Item({required this.quantity});
}
```

The function is `bool Function(T?)`. Return `true` for valid.

## How the generator resolves rules

For each `@Validate<T>([rule1, rule2, ...])`, the generator:

1. Determines `FieldContext` from `T`: `String` → `string`, `List<_>` → `iterable`, other → `generic`.
2. Iterates the rule list. Each rule annotation is dispatched to a handler registered for its class.
3. Handlers that support the field's `FieldContext` emit the check inline. E.g. `MinLength` emits a
   string-length check for `string` context and an item-count check for `iterable` context.
4. If a handler doesn't support the context (e.g. `OneOf` on a non-string/non-generic field), the
   builder logs a warning and skips the rule.

### Available contexts per handler

| Rule | `string` | `iterable` | `generic` |
|------|:---:|:---:|:---:|
| `Required` | ✓ | ✓ | ✓ |
| `Nullable` | ✓ | ✓ | ✓ |
| `MinLength` | ✓ (chars) | ✓ (items) | — |
| `MaxLength` | ✓ (chars) | ✓ (items) | — |
| `OneOf` | ✓ | — | ✓ |
| `Inline` | ✓ | ✓ | ✓ |
| `AsyncInline` | ✓ | ✓ | ✓ |
| `CustomRule` | ✓ | ✓ | ✓ |
| `AsyncCustomRule` | ✓ | ✓ | ✓ |

## Async refine

Cross-field checks can also be async:

```dart
@RefineFn(dependsOn: ['email', 'username'])
Future<void> noDuplicate(FailFn fail, {String? email, String? username}) async {
  if (email != null && username != null) {
    final exists = await database.userExists(email: email, username: username);
    if (exists) fail(message: 'Email or username already taken');
  }
}
```

The generator detects `Future<void>` and inserts `await` before the call.
