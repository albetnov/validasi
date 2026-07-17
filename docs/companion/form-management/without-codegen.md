# Without Codegen

You can use `validasi_ui` without annotations or `build_runner`. Define
`ValidasiField` instances manually and register them with the form controller.
This is useful for quick prototypes, dynamic forms, or when you prefer explicit
control over generated code.

## Manual field definition

```dart
import 'package:validasi/validasi.dart';
import 'package:validasi_ui/validasi_ui.dart';

class User {
  final String name;
  final String email;

  const User({required this.name, required this.email});
}

// Define fields manually by subclassing ValidasiField<T, V> — it's abstract with
// only a `const` constructor, so there's no generative `ValidasiField(name: ..., ...)`.
class NameField extends ValidasiField<User, String> {
  const NameField();

  @override
  String get name => 'name';

  @override
  String? extract(User owner) => owner.name;

  @override
  ValidasiResult<String> validate(String? value) =>
      Validasi.string([Rules.string.minLength(2)]).validate(value);
}

class EmailField extends ValidasiField<User, String> {
  const EmailField();

  @override
  String get name => 'email';

  @override
  String? extract(User owner) => owner.email;

  @override
  ValidasiResult<String> validate(String? value) =>
      Validasi.string([Rules.string.minLength(5)]).validate(value);
}

// Keep one const instance per field, the same way generated code exposes
// `UserFields.name`/`UserFields.email` — the controller keys its internal
// state off the field object itself, so reuse these instances everywhere.
const nameField = NameField();
const emailField = EmailField();
```

`ValidasiField<T, V>` is abstract — subclass it and override:

| Member | Description |
|--------|-------------|
| `name` | `String` getter — unique field identifier (used for error paths) |
| `extract(T owner)` | `V? Function(T)` — reads the field value from a model instance |
| `validate(V? value)` | `ValidasiResult<V> Function(V?)` — the sync validation pipeline |
| `validateAsync(V? value)` | Optional — defaults to calling `validate`; override to add async rules (see below) |

## Defining a schema

`ValidasiSchema<T>` is likewise abstract with only a `const` constructor — subclass it and
override `allocate`:

```dart
class UserSchema extends ValidasiSchema<User> {
  const UserSchema();

  @override
  User allocate(ValidasiFieldReader<User> reader) => User(
    name: reader.getValue(nameField) as String,
    email: reader.getValue(emailField) as String,
  );
}

const userSchema = UserSchema();
```

## Form widget

```dart
ValidasiForm(
  schema: userSchema,
  builder: (context, submit) => Column(
    children: [
      ValidasiFormField(
        field: nameField,
        builder: (context, state) => TextField(
          onChanged: state.onChanged,
          decoration: InputDecoration(
            labelText: 'Name',
            errorText: state.errorText,
          ),
        ),
      ),
      ValidasiFormField(
        field: emailField,
        builder: (context, state) => TextField(
          onChanged: state.onChanged,
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: state.errorText,
          ),
        ),
      ),
      ElevatedButton(
        onPressed: submit((user) {
          print('Saved: ${user.name}');
        }),
        child: const Text('Submit'),
      ),
    ],
  ),
);
```

## Using ValidasiTextField manually

```dart
ValidasiTextField(
  field: nameField,
  builder: (context, state, controller) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: 'Name',
      errorText: state.errorText,
    ),
  ),
),
```

`ValidasiTextField` automatically handles `TextEditingController` creation,
form-value sync, and disposal — just pass `controller` to your `TextField`.

## Manual ValidasiField with async validation

`validateAsync` is a regular overridable method on `ValidasiField<T, V>` — its default
implementation just delegates to `validate`, so override it to layer async checks on top:

```dart
class EmailField extends ValidasiField<User, String> {
  const EmailField();

  @override
  String get name => 'email';

  @override
  String? extract(User owner) => owner.email;

  @override
  ValidasiResult<String> validate(String? value) =>
      Validasi.string([Rules.string.minLength(5)]).validate(value);

  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async {
    final syncResult = validate(value);
    if (!syncResult.isValid) return syncResult; // don't hit the network on invalid input

    if (value != null && value.isNotEmpty) {
      final available = await checkEmailAvailability(value);
      if (!available) {
        return ValidasiResult.error(
          ValidationError(rule: 'email', message: 'Email already taken'),
        );
      }
    }
    return syncResult;
  }
}
```

The form controller calls `validateAsync` when the form/field is validated via
`controller.validateAsync()`/`validateFieldAsync()` — which is also what `submit.async(...)`
uses under the hood (see [Widgets Reference](/companion/form-management/widgets)).

## When to skip codegen

- **Prototyping** — iterate on form structure without running `build_runner` every change.
- **Dynamic forms** — form fields are determined at runtime (e.g. from a JSON schema).
- **Small apps** — a handful of fields where the overhead of annotations isn't worth it.
- **Non-Dart models** — the model class is defined in another language or generated by an
  external tool.

## When to use codegen

- **Type safety** — generated `XFields<V>` ensures `field` and `value` types match.
- **Ergonomics** — `UserFields.name` instead of manually tracking const field objects.
- **Maintainability** — add a field to the model and `build_runner` emits everything.
- **Cross-field** — `@RefineFn` is only available through codegen.
- **Refactoring** — rename a field and the generated code follows.
