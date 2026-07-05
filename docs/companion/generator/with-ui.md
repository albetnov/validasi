# With Form Management

When using `validasi_ui` for Flutter forms, codegen provides the field keys and
schema that bridge your model to the form layer. This page covers the full pipeline:
annotations → generated code → form widgets.

## Dependencies

```bash
flutter pub add validasi_ui validasi_annotation
flutter pub add dev:build_runner dev:validasi_gen
```

> `validasi_ui` re-exports `validasi`, so you don't need to add it separately.

## Build options

Enable all form-related options in `build.yaml`:

```yaml
targets:
  $default:
    builders:
      validasi_gen:validasi:
        options:
          generateFields: true
          generateSchema: true
          generateValidateForm: true
```

| Option | What it does |
|--------|-------------|
| `generateFields` | Emit `UserFields` sealed class — used in `ValidasiFormField(field: UserFields.name)` |
| `generateSchema` | Emit `UserFields.schema` — passed to `ValidasiForm(schema: UserFields.schema)` |
| `generateValidateForm` | Emit `validateForm_User(controller)` — form-aware validation that reads from controller state |

## Model definition

```dart
// user.dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.g.dart';

@ValidateClass()
class User {
  @Validate<String>([Required(), MinLength(2), MaxLength(100)])
  final String name;

  @Validate<String>([MinLength(5)])
  final String email;

  @Validate<int>([MinLength(1)])
  final int age;

  const User({required this.name, required this.email, required this.age});
}
```

Run the generator:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## What gets generated

The generator produces `user.g.dart` with:

```dart
// Sealed field key hierarchy — one const per field
sealed class UserFields<V> extends ValidasiKey<User>
    implements ValidasiField<User, V> {
  const UserFields._();

  static const UserFields<String> name = UserNameField();
  static const UserFields<String> email = UserEmailField();
  static const UserFields<int> age = UserAgeField();

  // Schema for form allocation
  static const ValidasiSchema<User> schema = _UserSchema();
}

// Private schema implementation
class _UserSchema extends ValidasiSchema<User> {
  const _UserSchema();

  @override
  User allocate(ValidasiFieldReader<User> reader) {
    return User(
      name: reader.getValue(UserFields.name) as String,
      email: reader.getValue(UserFields.email) as String,
      age: reader.getValue(UserFields.age) as int,
    );
  }
}
```

## Flutter form

```dart
import 'package:flutter/material.dart';
import 'package:validasi_ui/validasi_ui.dart';
import 'user.dart';

class UserFormPage extends StatelessWidget {
  const UserFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Form')),
      body: ValidasiForm(
        schema: UserFields.schema,
        builder: (context, submit) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ValidasiTextField(
                field: UserFields.name,
                builder: (context, state, controller) => TextField(
                  controller: controller,
                  onChanged: state.onChanged,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: state.errorText,
                  ),
                ),
              ),
              ValidasiTextField(
                field: UserFields.email,
                builder: (context, state, controller) => TextField(
                  controller: controller,
                  onChanged: state.onChanged,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: state.errorText,
                  ),
                ),
              ),
              ValidasiFormField(
                field: UserFields.age,
                builder: (context, state) => TextField(
                  onChanged: (raw) => state.onChanged(int.tryParse(raw)),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    errorText: state.errorText,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: submit((user) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved: ${user.name}, ${user.age}')),
                  );
                }),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Key points:

- `ValidasiForm(schema: UserFields.schema)` — the schema provides the `allocate()` method that builds your model on submit.
- `ValidasiTextField<T, V>` — wraps text fields with automatic `TextEditingController` lifecycle. The builder receives `(context, state, controller)`.
- `ValidasiFormField<T, V>` — use for non-text fields (e.g. `int` age with `int.tryParse`).
- `state.onChanged` pushes values into the form; `state.errorText` surfaces the first error.
- `submit((user) { ... })` validates all fields, builds your model via the schema, and calls your callback.
