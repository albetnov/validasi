# Form Management (experimental)

> **Experimental** — API subject to change. Feedback and contributions are welcome!

The `validasi_ui` package provides headless form management for Flutter, built on top of Validasi. It brings a React Hook Form–style controller + builder pattern to Flutter, using [signals](https://pub.dev/packages/signals) for fine-grained reactivity.

`validasi` is re-exported from this package, so you do **not** need to add it as a separate dependency.

## Setup

```yaml
dependencies:
  validasi_ui: ^0.1.0-dev.1
  validasi_annotation: ^0.1.0-dev.2

dev_dependencies:
  build_runner: ^2.4.0
  validasi_gen: ^0.1.0-dev.2
```

## Recommended: pair with `validasi_gen`

`validasi_ui` is designed to be driven by code-generated field schemas. Enable all build options in your `build.yaml`:

```yaml
targets:
  $default:
    builders:
      validasi_gen:validasi:
        options:
          generateFields: true
          generateAssemble: true
          generateValidateForm: true
```

- `generateFields: true` — emits typed `YourModelFields<V>` sealed hierarchy for field binding
- `generateAssemble: true` — emits `assemble_YourModel(controller)` to materialise your model on submit
- `generateValidateForm: true` — emits `validateForm_YourModel(controller)` for form-aware validation that reads from controller state and runs refines

Then annotate your model:

```dart
// user.dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.g.dart';

@ValidateClass(generateFields: true)
class User {
  @Validate.string([MinLength(2), MaxLength(100)])
  final String name;

  @Validate.string([MinLength(3), MaxLength(100)])
  final String email;

  @Validate([MinLength(1)])
  final int age;

  const User({required this.name, required this.email, required this.age});
}
```

Run the generator:

```bash
dart run build_runner build
```

## Quick start

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
      body: ValidasiForm<User>(
        assembler: assemble_User,
        builder: (context, submit) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ValidasiFormField<User, String>(
                field: UserFields.name,
                builder: (context, state) => TextField(
                  onChanged: state.onChanged,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: state.errorText,
                  ),
                ),
              ),
              ValidasiFormField<User, String>(
                field: UserFields.email,
                builder: (context, state) => TextField(
                  onChanged: state.onChanged,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: state.errorText,
                  ),
                ),
              ),
              ValidasiFormField<User, int>(
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

## Core widgets

### `ValidasiForm<T>`

The root widget. Provides an `InheritedWidget` scope for descendant `ValidasiFormField`s.

| Parameter | Description |
|---|---|
| `builder` | `Widget Function(BuildContext, SubmitHandler<T>)` — your UI |
| `controller` | Optional. Pass your own `ValidasiFormController<T>` for external control |
| `assembler` | Builds your model from controller state on submit (use the generated `assemble_YourModel`) |
| `mode` | When fields first validate: `onSubmit` (default), `onBlur`, `onChange` |
| `reValidateMode` | After first validation: `onChange` (default), `onBlur` |
| `initialValues` | Optional `T` used to seed every registered field |
| `shouldUnregister` | When `true` (default), fields auto-unregister on widget unmount |

### `ValidasiFormField<T, V>`

Binds a `ValidasiField<T, V>` to a builder. Each instance rebuilds only when its own signals change.

| Parameter | Description |
|---|---|
| `field` | The `ValidasiField` to bind (from the generated `YourModelFields`) |
| `builder` | `Widget Function(BuildContext, ValidasiFieldState<V>)` — your field UI |
| `mode` | Per-field override of the form's `ValidationMode` |
| `disabled` | When `true`, skips validation and clears errors |
| `validator` | Optional `Future<String?> Function(V?)` for async validation |
| `debounceDuration` | Debounce for async validation (default: 300ms) |

### `ValidasiFieldState<V>`

What your builder receives:

| Member | Type | Description |
|---|---|---|
| `value` | `V?` | Current field value |
| `errorText` | `String?` | First error message or `null` |
| `hasError` | `bool` | `errors.isNotEmpty` |
| `onChanged` | `void Function(V?)` | Push a new value into the form |
| `onFocusChange` | `void Function(bool)?` | Wire to `FocusNode` for `onBlur` |
| `isDirty` | `bool` | Value changed from initial |
| `isTouched` | `bool` | User has interacted |
| `isValidating` | `bool` | Async validation in progress |
| `disabled` | `bool` | Field is disabled |
| `setError` | `void Function(String, {bool overwrite})` | Manually set an error |
| `clearErrors` | `void Function()` | Clear all errors on the field |

## `ValidasiFormController<T>`

For external or imperative control. Access via `ValidasiForm.of<T>(context)`.

| Member | Description |
|---|---|
| `validate()` | Validate all fields + cross-field rules |
| `validateField<V>(field)` | Validate one field |
| `getValue<V>(field)` / `setValue<V>(field, v)` | Read/write a single field |
| `getValues()` | Map of all field values |
| `setInitialValues(model)` | Reset every field from a model |
| `reset()` | Restore initial values, clear errors |
| `isDirty` / `isTouched` | Any field dirty/touched? |
| `isSubmitted` | `true` after first submit attempt |
| `isValid` | `true` if every field has no errors |
| `setError<V>(field, msg, {overwrite})` | Manually set an error |
| `clearErrors<V>(field)` / `clearAllErrors()` | Clear errors |
| `setFieldDisabled<V>(field, bool)` | Enable/disable at runtime |
| `submit(onSubmit)` | Validate, then call `onSubmit(assembler(this))` |

## Validation modes

| Mode | First validation | Re-validation |
|---|---|---|
| `onSubmit` (default) | On submit | Per `reValidateMode` |
| `onBlur` | On blur | Per `reValidateMode` |
| `onChange` | On change | Per `reValidateMode` |

`ReValidationMode.onChange` (default) and `ReValidationMode.onBlur` apply after the field has been validated at least once.

## Field arrays

`validasi_ui` supports dynamic arrays of scalar and object items.

**Scalar arrays** — use `appendArrayItem`, `insertArrayItem`, `removeArrayItem`, `swapArrayItems` on the controller. Each item registers as a sub-field with name `parentName[index]`.

**Object arrays** — when `validasi_gen` emits field classes with `withIndex(int)`, manage arrays of objects with full sub-field support:

```dart
final nameField = PersonFields.name.withIndex(0);
final ageField = PersonFields.age.withIndex(0);
```

## Async validation

Prefer to define async validation inline in your schema using `AsyncInline` inside a `@Validate` annotation:

```dart
Future<bool> _checkEmailAvailable(String? email) async {
  if (email == null) return false;
  final taken = await checkEmailTaken(email);
  return !taken;
}

@ValidateClass(generateFields: true)
class User {
  @Validate.string([MinLength(3), AsyncInline(_checkEmailAvailable)])
  final String email;

  const User({required this.email});
}
```

The generator wires the check into both `validateAsync()` and `validateForm_X(ctrl)`. The `ValidasiFormField` picks up the result automatically — no extra configuration needed.

For quick prototyping or one-off logic without touching your schema, you can also pass an inline validator directly to `ValidasiFormField`:

```dart
ValidasiFormField<User, String>(
  field: UserFields.email,
  validator: (email) async {
    if (email == null) return null;
    final taken = await checkEmailTaken(email);
    return taken ? 'Email already taken' : null;
  },
  builder: /* ... */,
);
```

The validator is debounced (default 300ms) and uses a version counter to discard stale results. Errors appear alongside sync errors in `state.errors` with `state.isValidating` indicating in-flight checks.

## Cross-field validation

Use `@RefineFn` on a method in your model to define rules that span multiple fields:

```dart
@ValidateClass(generateFields: true)
class User {
  final String email;
  final String confirmEmail;

  @RefineFn(dependsOn: ['email', 'confirmEmail'])
  void emailsMatch(FailFn fail, {String? email, String? confirmEmail}) {
    if (email != null && confirmEmail != null && email != confirmEmail) {
      fail(message: 'Emails do not match', path: ['confirmEmail']);
    }
  }
}
```

The generator wires the refine into both `validateAsync()` (using `this`) and `validateForm_X(ctrl)` (using `ctrl.getValue(...)`). Cross-field errors surface as `FieldCrossError` alongside the field's own errors, so you can render them inline at the dependent field.

For async cross-field rules, return `Future<void>`:

```dart
@RefineFn(dependsOn: ['email', 'confirmEmail'])
Future<void> emailsMatch(FailFn fail, {String? email, String? confirmEmail}) async {
  // ...
}
```
