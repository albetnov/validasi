# Validasi UI

Headless form management for Flutter, built on top of [`validasi`](../validasi). Brings the React Hook Form–style controller + builder pattern to Flutter, using [signals](https://pub.dev/packages/signals) for fine-grained reactivity.

> Development release - API subject to change. Feedback welcome!

[Repository](https://github.com/albetnov/validasi) | [Documentation](https://albetnov.github.io/validasi)

## Why

`validasi` gives you a composable, type-safe validation engine. `validasi_ui` adds the missing form-management layer for Flutter:

- **Headless** — no widgets forced on you, you build the UI from primitives.
- **Type-safe** — generic over your model `T` and each field's value `V`.
- **Reactive** — only the widgets that read a changed signal rebuild.
- **Immutable models** — assemble your model from controller state on submit.

`validasi` is re-exported from this package, so you do **not** need to add it as a separate dependency.

## Recommended: pair with `validasi_gen`

`validasi_ui` is designed to be driven by code-generated field schemas. Annotate your model with `@ValidateClass(generateFields: true)` and `validasi_gen` emits a typed `YourModelFields<V>` sealed hierarchy plus an `assemble_YourModel` function — no hand-written field plumbing.

```yaml
flutter pub get validasi_ui validasi_annotation dev:validasi_gen dev:build_runner
```

Define the model and its rules in one place:

```dart
// user.dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.g.dart';

String? _emailMatchesName(V? Function<V>(ValidasiField<User, V>) get) {
  final email = get(UserFields.email);
  final name = get(UserFields.name);
  if (email != null && name != null && email.startsWith(name)) {
    return 'Email should not start with name';
  }
  return null;
}

@ValidateClass(generateFields: true)
class User {
  @Validate.string([MinLength(2), MaxLength(100)])
  final String name;

  @Validate.string([MinLength(3), MaxLength(100)])
  @ValidateWith(_emailMatchesName, dependsOn: {#name})
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

This produces `user.g.dart` containing the `UserFields<V>` hierarchy, `assemble_User`, and a `UserCrossFields` cross-field key class. You can also pass `assemble_User` directly to `ValidasiForm.assembler`.

## Quick start

```dart
// main.dart
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
                    SnackBar(
                      content: Text(
                        'Saved: ${user.name}, ${user.email}, ${user.age}',
                      ),
                    ),
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

A full working example lives in [`example/`](./example) — `dart run` it from `packages/validasi_ui/example` to see it live.

## Concepts

### `ValidasiForm<T>`

The root widget. Provides an `InheritedWidget` scope for descendant `ValidasiFormField`s.

| Parameter | Description |
|---|---|
| `builder` | `Widget Function(BuildContext, SubmitHandler<T>)` — your UI |
| `controller` | Optional. Pass your own `ValidasiFormController<T>` for external control |
| `assembler` | Builds your model `T` from the controller state on submit (use the generated `assemble_YourModel`) |
| `mode` | When fields first validate: `onSubmit` (default), `onBlur`, `onChange` |
| `reValidateMode` | After first validation: `onChange` (default), `onBlur` |
| `initialValues` | Optional `T` used to seed every registered field |

`SubmitHandler<T>` is `VoidCallback Function(void Function(T) onSubmit)` — call the returned `VoidCallback` from your button's `onPressed` to trigger submit with validation + assembly.

### `ValidasiFormField<T, V>`

Binds a `ValidasiField<T, V>` to a builder. Each instance rebuilds only when its own signals change.

| Parameter | Description |
|---|---|
| `field` | The `ValidasiField` to bind (from the generated `YourModelFields`) |
| `builder` | `Widget Function(BuildContext, ValidasiFieldState<V>)` — your field UI |
| `mode` | Per-field override of the form's `ValidationMode` |
| `reValidateMode` | Per-field override of the form's `ReValidationMode` |

### `ValidasiFieldState<V>`

What your builder receives.

| Member | Type | Description |
|---|---|---|
| `value` | `V?` | Current field value |
| `errors` | `List<ValidationError>` | Validation errors (own + cross-field) |
| `errorText` | `String?` | Convenience — `errors.first.message` or `null` |
| `hasError` | `bool` | `errors.isNotEmpty` |
| `onChanged` | `void Function(V?)` | Push a new value into the form |
| `validate` | `void Function()` | Manually trigger validation for this field |
| `onFocusChange` | `void Function(bool)?` | Wire to `FocusNode` — triggers `onBlur` validation |
| `isDirty` | `bool` | `value != initialValue` |
| `isTouched` | `bool` | User has interacted with this field |
| `isPristine` | `bool` | `!isDirty` |

### `ValidasiFormController<T>`

For external/imperative control. Lives on `ValidasiForm.of<T>(context)`.

| Member | Description |
|---|---|
| `isSubmitted` | `true` once the user has attempted submit |
| `isLoading` | Async-submit flag (you drive it) |
| `isDirty` / `isPristine` | Any field dirty? |
| `isTouched` | Any field touched? |
| `fieldErrors` | `List<FieldErrors>` snapshot of every field's errors |
| `getFieldController<V>(field)` | Low-level `ValidasiFieldSignals<V>` access |
| `register<V>(field, {initialValue})` | Pre-register a field with a value |
| `setInitialValues(model)` | Reset every field to values extracted from `model` |
| `getValue<V>(field)` / `setValue<V>(field, v)` | Read/write a single field |
| `getValues()` | `Map<ValidasiField, dynamic>` of all values |
| `getErrors<V>(field)` | `List<FieldError>` for one field |
| `validate()` | Validate all fields + cross-field rules; returns `isValid` |
| `validateField<V>(field)` | Validate one field |
| `isFieldDirty<V>(field)` / `isFieldTouched<V>(field)` | Per-field state |
| `markSubmitted()` | Set `isSubmitted = true` |
| `submit(onSubmit)` | Returns a `VoidCallback` that validates, then calls `onSubmit(assembler(this))` |
| `reset()` | Restore initial values, clear all errors + touched + submitted |
| `isValid` | `true` if every field has no errors |

### Field errors

Errors come back as a sealed `FieldError` hierarchy:

- `FieldValidationError` — produced by the field's own rules
- `FieldCrossError` — produced by a `crossValidator` across multiple fields; carries `crossFieldName` and `dependsOn` for UI

`FieldErrors` groups them per field: `name`, `errors`, `isValid`, `hasCrossErrors`, `errorText`.

## Validation modes

the `mode` let you set initial mode / while `reValidateMode` let you configure when fields re-validate after the first validation (typically after submit). The table below summarizes when validation runs in each mode:

| | First validation | Re-validation after change |
|---|---|---|
| `ValidationMode.onSubmit` (default) | on submit | per `reValidateMode` |
| `ValidationMode.onBlur` | on blur | per `reValidateMode` |
| `ValidationMode.onChange` | on change | per `reValidateMode` |

`ReValidationMode.onChange` (default) and `ReValidationMode.onBlur` apply once the field has been validated at least once (typically after the first submit attempt).

Per-field overrides take precedence over the form-level value.

## Patterns

### External controller

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _controller = ValidasiFormController<User>(assembler: assemble_User);

  @override
  Widget build(BuildContext context) {
    return ValidasiForm<User>(
      controller: _controller,
      builder: (context, submit) => YourForm(submit: submit),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Programmatic value + reset

```dart
final c = ValidasiForm.of<User>(context);

c.setValue(UserFields.name, 'Ada');
c.validateField(UserFields.name);

c.setInitialValues(User(name: 'Ada', email: 'ada@example.com'));
c.reset();
```

### Cross-field validation

Cross-field errors are returned alongside the field's own errors and surface as `FieldCrossError`, so you can render cross-field messages inline at the dependent field. With `validasi_gen`, define the rule as a top-level function and tag the field with `@ValidateWith`:

```dart
String? _emailMatchesName(V? Function<V>(ValidasiField<User, V>) get) { ... }

@Validate.string([MinLength(3)])
@ValidateWith(_emailMatchesName, dependsOn: {#name})
final String email;
```

The generated `crossValidator` and `crossDependsOn` wire the error into the dependent field automatically.

## Manual fields (without codegen)

`validasi_ui` does not require `validasi_gen` — you can implement `ValidasiField<T, V>` by hand. You'll typically want to:

1. Declare a sealed field class (mirroring what `validasi_gen` would emit) holding static `const` instances.
2. Implement `name`, `extract`, `validate`, and — for cross-field rules — `crossFieldKey`, `crossValidator`, and `crossDependsOn`.
3. Write your own `assemble_User(ValidasiFormController<User> c)` that calls `c.getValue(...)` for each field.

This works, but it's boilerplate the generator removes. The generated path is the recommended one; reach for manual fields only when codegen isn't an option (e.g. dynamic schemas).

## Feature status

| Feature | Status |
|---|---|
| Form / field builders | ✅ |
| Imperative controller | ✅ |
| `onSubmit` / `onBlur` / `onChange` modes | ✅ |
| Per-field mode override | ✅ |
| Dirty / touched / pristine tracking | ✅ |
| Imperative `validate` / `validateField` | ✅ |
| `reset()` to initial values | ✅ |
| External / shared controller | ✅ |
| Cross-field validation errors | ✅ |
| Async submit with `isLoading` | ✅ |
| Generated fields via `validasi_gen` | ✅ |

## License

MIT — see repository for details.
