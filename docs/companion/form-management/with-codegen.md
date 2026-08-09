# With Codegen

The recommended path: annotate your model, run `build_runner`, use the generated
`XFields` and `schema` in your form.

## 1. Model + annotations

```dart
// lib/models/user.dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.validasi.dart';

@ValidateClass()
class User {
  @Validate<String>([Required(), MinLength(2), MaxLength(100)])
  final String name;

  @Validate<String>([MinLength(5)])
  final String email;

  @Validate<int>([Positive()])
  final int age;

  const User({required this.name, required this.email, required this.age});
}
```

## 2. Generate

```yaml
# build.yaml
targets:
  $default:
    builders:
      validasi_gen:validasi:
        options:
          generateFields: true
          generateSchema: true
          generateValidateForm: true
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 3. Form widget

```dart
import 'package:flutter/material.dart';
import 'package:validasi_ui/validasi_ui.dart';
import 'models/user.dart';

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
              // Text field with auto TextEditingController
              ValidasiTextField(
                field: UserFields.name,
                builder: (context, state, controller) => TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: state.errorText,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ValidasiTextField(
                field: UserFields.email,
                builder: (context, state, controller) => TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: state.errorText,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Non-string field — parse manually
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
                  // user is typed User, allocated by schema
                  saveUser(user);
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

## 4. Submit flow

1. `submit((user) { ... })` calls `controller.validate()`.
2. If valid, the schema's `allocate(controller)` builds your model from registered field values.
3. Your callback receives the fully typed `User` instance.

```dart
// Submit with loading state
ElevatedButton(
  onPressed: controller.isSubmitted && !controller.isValid
      ? null  // disable after failed submit
      : submit((user) {
          setState(() => _loading = true);
          saveUser(user).then((_) {
            setState(() => _loading = false);
            Navigator.pop(context);
          });
        }),
  child: const Text('Submit'),
),
```

## 5. Accessing the controller

```dart
final controller = ValidasiForm.of<User>(context);

// Check state
print(controller.isDirty);
print(controller.isTouched);
print(controller.isValid);

// Programmatic control
controller.validate();
controller.setValue(UserFields.email, 'new@email.com');
controller.reset();

// Read values
final email = controller.getValue(UserFields.email);
final allValues = controller.getValues();
```

## 6. Async validation with codegen

```dart
Future<bool> _emailAvailable(String? email) async {
  if (email == null) return false;
  final taken = await checkEmailTaken(email);
  return !taken;
}

@ValidateClass()
class User {
  @Validate<String>([Required(), MinLength(5), AsyncInline(_emailAvailable)])
  final String email;

  const User({required this.email});
}
```

The generator wires `AsyncInline` into the field's `validateAsync()`. The form
controller automatically runs async validation when the field is validated.

> **Once any field has an async rule, switch your submit button to `submit.async(...)`.**
> The generated sync `validate()` (and therefore the sync `submit(...)` path from steps 3-5)
> throws `StateError('Async rules cannot be used with validate(). Use validateAsync() instead.')`
> the moment it reaches a field with an async rule like this `AsyncInline`. Use
> `submit.async((user) async { ... })` instead — see the `ValidasiSubmit<T>` section of
> [Widgets Reference](/companion/form-management/widgets) for both entry points.

The builder receives `state.isValidating` to show a spinner:

```dart
ValidasiTextField(
  field: UserFields.email,
  builder: (context, state, controller) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: 'Email',
      errorText: state.errorText,
      suffixIcon: state.isValidating
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
    ),
  ),
),
```

## 7. Cross-field with codegen

```dart
@ValidateClass()
class SignUpForm {
  final String password;
  final String confirmPassword;

  @RefineFn(dependsOn: ['password', 'confirmPassword'])
  static void passwordsMatch(FailFn fail, {String? password, String? confirmPassword}) {
    if (password != null && confirmPassword != null && password != confirmPassword) {
      fail(message: 'Passwords do not match', path: ['confirmPassword']);
    }
  }

  const SignUpForm({required this.password, required this.confirmPassword});
}
```

Cross-field errors appear alongside per-field errors in the form controller.
The `generateValidateForm: true` option enables `validateForm_SignUpForm(controller)`
which reads values from the controller and runs refines.
