# Validasi UI

Headless form management for Flutter, built on top of [`validasi`](https://pub.dev/packages/validasi). Brings the React Hook Form–style controller + builder pattern to Flutter, using [signals](https://pub.dev/packages/signals) for fine-grained reactivity.

> **Experimental** — API subject to change. Feedback and contributions are welcome!

[Repository](https://github.com/albetnov/validasi) | [Documentation](https://albetnov.github.io/validasi)

## Why

`validasi` gives you a composable, type-safe validation engine. `validasi_ui` adds the missing form-management layer for Flutter:

- **Headless** — no widgets forced on you, you build the UI from primitives.
- **Type-safe** — generic over your model `T` and each field's value `V`.
- **Reactive** — only the widgets that read a changed signal rebuild.
- **Immutable models** — assemble your model from controller state on submit.

`validasi` is re-exported from this package, so you do **not** need to add it as a separate dependency.

## Recommended: pair with `validasi_gen`

`validasi_ui` is designed to be driven by code-generated field schemas. Annotate your model with
`@ValidateClass()` and enable `generateSchema`/`generateValidateForm` in your build options, and
`validasi_gen` emits a typed `YourModelFields<V>` sealed hierarchy plus a `schema` your `ValidasiForm`
can consume directly — no hand-written field plumbing.

```yaml
flutter pub get validasi_ui validasi_annotation dev:validasi_gen dev:build_runner
```

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

Define the model and its rules in one place:

```dart
// user.dart
import 'package:validasi/validasi.dart';
import 'package:validasi_annotation/validasi_annotation.dart';

part 'user.validasi.dart';

@ValidateClass()
class User {
  @Validate<String>([Required(), MinLength(2), MaxLength(100)])
  final String name;

  @Validate<String>([Required(), MinLength(3), MaxLength(100)])
  final String email;

  @Validate<int>([Positive()])
  final int age;

  const User({required this.name, required this.email, required this.age});
}
```

Cross-field checks — e.g. a confirm-password field, or a check that spans `name` and `email` —
go through `@RefineFn` or a cross-field sugar annotation instead of a per-field annotation; see
[Cross-field validation](#cross-field-validation) below.

Run the generator:

```bash
dart run build_runner build
```

This produces `user.validasi.dart` containing the `UserFields<V>` sealed hierarchy and, because
`generateSchema`/`generateValidateForm` are on, `UserFields.schema` (pass straight to
`ValidasiForm(schema: UserFields.schema)`) and `validateForm_User(controller)` for the cross-field
rules. Both `generateSchema` and `generateValidateForm` are no-ops unless `generateFields` is also
`true` — it gates them.

## Quick start

Generic type arguments (`<T>`, `<T, V>`) are **inferred** from the field or schema you pass — you rarely need to spell them out.

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
      body: ValidasiForm(
        schema: UserFields.schema,
        builder: (context, submit) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ValidasiFormField(
                field: UserFields.name,
                builder: (context, state) => TextField(
                  onChanged: state.onChanged,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: state.errorText,
                  ),
                ),
              ),
              ValidasiFormField(
                field: UserFields.email,
                builder: (context, state) => TextField(
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

The root widget. Provides an `InheritedWidget` scope for descendant `ValidasiFormField`s. `T` is inferred from the `schema` argument.

| Parameter | Description |
|---|---|
| `schema` | Required. `ValidasiSchema<T>` — builds your model `T` from the controller state on submit (use the generated `UserFields.schema`) |
| `builder` | `Widget Function(BuildContext, ValidasiSubmit<T>)` — your UI |
| `controller` | Optional. Pass your own `ValidasiFormController<T>` for external control |
| `formValidator` | Optional. Custom form-level/cross-field validator; auto-discovered from the schema when `generateValidateForm` generated one |
| `mode` | When fields first validate: `onSubmit` (default), `onBlur`, `onChange` |
| `reValidateMode` | After first validation: `onChange` (default), `onBlur` |
| `initialValues` | Optional `T` used to seed every registered field |
| `shouldUnregister` | When `true`, fields auto-unregister on widget unmount; `false` (default) keeps values (wizards) |

`ValidasiSubmit<T>` is a callable class, not a plain function type — call it directly for sync
submit (`submit((user) { ... })`), or use `submit.async((user) async { ... })` when any field has
async rules (it awaits `validateAsync()` first; the sync path throws `StateError` if it hits an
async rule).

### `ValidasiFormField<T, V>`

Binds a `ValidasiField<T, V>` to a builder. Both `T` and `V` are inferred from the `field` argument — you only need to spell them when the field's type is lost (e.g. dynamic). Each instance rebuilds only when its own signals change.

| Parameter | Description |
|---|---|---|
| `field` | The `ValidasiField` to bind (from the generated `YourModelFields`) |
| `builder` | `Widget Function(BuildContext, ValidasiFieldState<V>)` — your field UI |
| `mode` | Per-field override of the form's `ValidationMode` |
| `reValidateMode` | Per-field override of the form's `ReValidationMode` |
| `disabled` | When `true`, skips validation, dirty/tracking, and clears errors |
| `validator` | Optional `Future<String?> Function(V?)` for async validation |
| `debounceDuration` | Debounce for async validation (default: 300ms) |
| `shouldUnregister` | Override form-level `shouldUnregister` for this field |

### `ValidasiTextField<T, V>`

Convenience wrapper around `ValidasiFormField` that manages a `TextEditingController` lifecycle and keeps it in sync with the form value. Unlike a plain `ValidasiFormField`, this widget handles the controller plumbing so you focus on building the UI.

```dart
ValidasiTextField<User, String>(
  field: UserFields.name,
  builder: (context, state, ctrl) => TextField(
    controller: ctrl,
    onChanged: state.onChanged,
    decoration: InputDecoration(
      labelText: 'Name',
      errorText: state.errorText,
    ),
  ),
)
```

| Parameter | Description |
|---|---|
| `field` | The `ValidasiField` to bind |
| `builder` | `Widget Function(BuildContext, ValidasiFieldState<V>, ValidasiTextController)` — receives the field state and a pre-synced controller |
| `controller` | Optional. Pass your own `ValidasiTextController` for programmatic access (`clear()`, `selection`, etc.) |
| `mode`, `reValidateMode`, `disabled`, `validator`, `debounceDuration`, `shouldUnregister` | Same as `ValidasiFormField` |

When `controller` is omitted, one is created internally and disposed with the widget. Pass one in when you need external control.

For non-`String` fields, wire parsing in the builder:

```dart
ValidasiTextField(
  field: UserFields.age,
  builder: (context, state, ctrl) => TextField(
    controller: ctrl,
    onChanged: (raw) => state.onChanged(int.tryParse(raw)),
    keyboardType: TextInputType.number,
    decoration: InputDecoration(errorText: state.errorText),
  ),
)
```

### `ValidasiTextController`

A `TextEditingController` subclass that serves as the bridge between your `TextField` and the `ValidasiFormController`. Use it with `ValidasiTextField` for programmatic control:

```dart
class _MyPage extends StatefulWidget { ... }
class _MyPageState extends State<_MyPage> {
  final _nameCtrl = ValidasiTextController();

  void _clearName() {
    _nameCtrl.clear();
  }

  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Widget build(context) => ValidasiTextField(
    field: UserFields.name,
    controller: _nameCtrl,
    builder: (context, state, ctrl) => TextField(
      controller: ctrl,
      onChanged: state.onChanged,
      decoration: InputDecoration(errorText: state.errorText),
    ),
  );
}
```

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
| `isValidating` | `bool` | Async validation in progress |
| `disabled` | `bool` | Field is disabled |
| `setError` | `void Function(String message, {bool overwrite})?` | Manually set an error (`overwrite: true` replaces existing, `false` only sets if error-free) |
| `clearErrors` | `void Function()?` | Clear all errors on the field |

### `ValidasiFormController<T>`

For external/imperative control. Lives on `ValidasiForm.of<T>(context)`. Methods that accept a `ValidasiField<T, V>` infer their `<V>` generic from the field argument — you don't need to spell it out at call sites.

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
| `getValues()` | `Map<ValidasiField, dynamic>` of all values (excludes array-items + disabled) |
| `getErrors<V>(field)` | `List<FieldError>` for one field |
| `validate()` | Validate all fields + cross-field rules; returns `isValid` |
| `validateField<V>(field)` | Validate one field |
| `isFieldDirty<V>(field)` / `isFieldTouched<V>(field)` | Per-field state |
| `markSubmitted()` | Set `isSubmitted = true` |
| `submit(onSubmit)` | Returns a `VoidCallback` that runs sync `validate()`, then calls `onSubmit(schema.allocate(this))` |
| `submitAsync(onSubmit)` | Async counterpart — returns a `Future<void> Function()` that runs `validateAsync()` first |
| `validateAsync()` / `validateFieldAsync<V>(field)` | Async counterparts of `validate()`/`validateField()` — await any async rules |
| `reset()` | Restore initial values, clear all errors + touched + submitted |
| `isValid` | `true` if every field has no errors |
| `setFieldDisabled<V>(field, disabled)` | Enable/disable a field at runtime |
| `setFieldValidator<V>(field, validator, {debounce})` | Connect an async validator |
| `triggerAsyncValidation<V>(field)` | Manually trigger async validation |
| `setError<V>(field, message, {overwrite})` | Manually set an error (`overwrite: true` replaces existing, `false` only sets if error-free) |
| `clearErrors<V>(field)` | Clear errors for one field |
| `clearAllErrors()` | Clear all field + form errors |
| `appendArrayItem<V>(field, value)` | Append an item to a `List<V>` field |
| `insertArrayItem<V>(field, index, value)` | Insert an item at a specific index |
| `removeArrayItem<V>(field, index)` | Remove an item by index |
| `swapArrayItems<V>(field, i, j)` | Swap two items |
| `getArrayItemField<V>(field, index)` | Get the synthetic `ValidasiField` for a scalar array item |
| `getArraySubField<SubV>(field, index, fieldName)` | Get an indexed sub-field for an object array item |
| `getArrayItemCount(field)` | Number of items in the array |
| `unregister<V>(field)` | Remove a field, dispose signal, clear subscriptions |

### Field errors

Errors come back as a sealed `FieldError` hierarchy — currently a single variant,
`FieldValidationError`, wrapping the underlying `ValidationError` (`rule`, `message`, `path`,
`details`). Cross-field errors distributed by a form-level validator (see
[Cross-field validation](#cross-field-validation)) arrive the same way, routed to whichever field
name they're `path`-targeted at.

`FieldErrors` groups them per field: `name`, `errors`, `isValid`, `errorText`.

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
  final _controller = ValidasiFormController(schema: UserFields.schema);

  @override
  Widget build(BuildContext context) {
    return ValidasiForm(
      controller: _controller,
      schema: UserFields.schema,
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

### Field arrays

`validasi_ui` supports dynamic arrays of both **scalar** and **object** items.

#### Scalar arrays

Use `appendArrayItem`, `insertArrayItem`, `removeArrayItem`, and `swapArrayItems` to manage a `List<V>` field. Each item registers as a sub-field with name `parentName[index]`, making per-item validation and error display possible.

```dart
final emailsField = ValidasiField<MyForm, List<String>>(...);

// Append
controller.appendArrayItem(emailsField, 'a@example.com');
controller.appendArrayItem(emailsField, 'b@example.com');

// Insert
controller.insertArrayItem(emailsField, 1, 'mid@example.com');

// Remove
controller.removeArrayItem(emailsField, 0);

// Swap
controller.swapArrayItems(emailsField, 0, 1);

// Get a specific item's field for reading/validating
final itemField = controller.getArrayItemField(emailsField, 0)!;
controller.setValue(itemField, 'updated@example.com');
```

In the widget tree, access array item fields dynamically:

```dart
final list = controller.getValue(field) ?? [];
for (int i = 0; i < list.length; i++) {
  final itemField = controller.getArrayItemField(field, i)!;
  // Use itemField with ValidasiFormField
  ValidasiFormField(
    field: itemField,
    builder: (context, state) => TextField(
      onChanged: state.onChanged,
      decoration: InputDecoration(errorText: state.errorText),
    ),
  );
}
```

Array sub-fields are excluded from `getValues()` — only the parent list field appears.

#### Object arrays

With `generateIndexedFields: true` in your build options, `validasi_gen` emits
`indexedFields`/`reconstructItem`/`reconstructAll` static methods on the nested item's own fields
class (e.g. `PersonFields` for a `List<Person>` field), which you wire into
`appendArrayItem`/`insertArrayItem` so the controller can create and reconstruct each row's
sub-fields:

```dart
controller.appendArrayItem(
  UserFields.previousPeople,
  newPerson,
  indexedFields: (index) => PersonFields.indexedFields<User>('previousPeople', index),
  reconstructItem: (ctrl, index) =>
      PersonFields.reconstructItem<User>(ctrl, UserFields.previousPeople, index),
  reconstructAll: (ctrl) => PersonFields.reconstructAll<User>(ctrl, UserFields.previousPeople),
);

// Access an indexed sub-field, e.g. row 0's `name`
final nameField = controller.getArraySubField(UserFields.previousPeople, 0, 'name');
```

Each sub-field has `name = 'previousPeople[0].name'`, delegates `validate()` to the original leaf
field, and works with `ValidasiFormField<T, V>` in the widget tree like any other field.

### Async validation

Pass an async validator to `ValidasiFormField` for server-side checks (e.g. email uniqueness):

```dart
ValidasiFormField(
  field: UserFields.email,
  validator: (email) async {
    if (email == null) return null;
    final taken = await checkEmailTaken(email);
    return taken ? 'Email already taken' : null;
  },
  builder: (context, state) => TextField(
    onChanged: state.onChanged,
    decoration: InputDecoration(
      errorText: state.errorText,
      suffixIcon: state.isValidating
          ? const CircularProgressIndicator(strokeWidth: 2)
          : null,
    ),
  ),
);
```

The validator is debounced (default 300ms) and uses a version counter to discard stale results from previous runs. Errors from async validation appear alongside sync errors in `state.errors`.

### Disabled fields

Set `disabled: true` on `ValidasiFormField` to skip validation, dirty/touched tracking, and value updates. Existing errors are cleared on disable.

`disabled` can also be toggled at runtime via `controller.setFieldDisabled(field, true)`.

### Cross-field validation

Cross-field checks are defined with `@RefineFn` (or a cross-field sugar annotation like
`@MatchesField`/`@RequiredAny`) on the model, not per-field. With `generateValidateForm: true`,
`validasi_gen` emits `validateForm_User(ValidasiFormController<User> controller)`, which
`ValidasiForm` auto-discovers and runs as its `formValidator` — cross-field errors are then
distributed to whichever field they're `path`-targeted at, appearing alongside that field's own
errors in `state.errors`/`controller.getErrors(field)`.

```dart
@ValidateClass()
class SignUpForm {
  @Validate<String>([Required(), MinLength(6)])
  final String password;

  @Validate<String>([Required()])
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

`@RefineFn` methods must be `static` — the generator emits a qualified call and has no instance to
call it on. See the `validasi_gen`/`validasi_annotation` docs for the full set of cross-field sugar
annotations.

## Manual fields (without codegen)

`validasi_ui` does not require `validasi_gen` — you can implement `ValidasiField<T, V>` and
`ValidasiSchema<T>` by hand. Both are abstract classes with only a `const` constructor — there's no
generative `ValidasiField(name: ..., extract: ..., validate: ...)` constructor, you subclass them:

```dart
class NameField extends ValidasiField<User, String> {
  const NameField();

  @override
  String get name => 'name';

  @override
  String? extract(User owner) => owner.name;

  @override
  ValidasiResult<String> validate(String? value) =>
      Validasi.string([Rules.string.minLength(2)]).validate(value);

  // Optional — defaults to calling validate(); override for async rules.
  @override
  Future<ValidasiResult<String>> validateAsync(String? value) async => validate(value);
}

class UserSchema extends ValidasiSchema<User> {
  const UserSchema();

  @override
  User allocate(ValidasiFieldReader<User> reader) => User(
    name: reader.getValue(const NameField()) as String,
    // ...one line per field
  );
}
```

Keep one `const` instance per field (mirroring how generated code exposes `UserFields.name`) since
the controller keys its internal state off the field object. There's no `crossFieldKey`/
`crossValidator`/`crossDependsOn` on manual fields — cross-field checks for hand-written fields go
through `ValidasiForm`'s `formValidator` parameter instead, which receives the controller directly.

This works, but it's boilerplate the generator removes. The generated path is the recommended one; reach for manual fields only when codegen isn't an option (e.g. dynamic schemas).

## Feature status

| Feature | Status |
|---|---|---|
| Form / field builders | ✅ |
| Imperative controller | ✅ |
| `onSubmit` / `onBlur` / `onChange` modes | ✅ |
| Per-field mode override | ✅ |
| Per-field re-validation mode override | ✅ |
| Dirty / touched / pristine tracking | ✅ |
| Imperative `validate` / `validateField` | ✅ |
| `reset()` to initial values | ✅ |
| External / shared controller | ✅ |
| Cross-field validation errors | ✅ |
| Async submit with `isLoading` | ✅ |
| Generated fields via `validasi_gen` | ✅ |
| Disabled fields | ✅ |
| Async validation (per-field) | ✅ |
| Manual `setError` (with `overwrite` control) | ✅ |
| `clearErrors` / `clearAllErrors` | ✅ |
| Scalar field arrays (`append`/`insert`/`remove`/`swap`) | ✅ |
| Object field arrays (`generateIndexedFields` codegen) | ✅ |
| `unregister` / `shouldUnregister` | ✅ |
| Field focus API | 🔮 |

## Contributing

### Project structure

```
lib/
  validasi_ui.dart              # barrel export (re-exports all public API)
  validasi.dart                 # re-exports package:validasi
  src/
    controller/
      controller.dart           # ValidasiFormController — core form logic
      watch_mixin.dart          # WatchMixin — watchValue / watch computed signals
    widgets/
      validasi_form.dart        # ValidasiForm + _FormScope (InheritedWidget)
      validasi_form_field.dart  # ValidasiFormField (field builder widget)
      validasi_text_controller.dart  # ValidasiTextController (TextEditingController subclass)
      validasi_text_form_field.dart  # ValidasiTextField (controller lifecycle wrapper)
      validasi_watch.dart       # ValidasiWatch, ValidasiWatchForm, ValidasiWatchField
    signals/
      field_signals.dart        # ValidasiFieldSignals — per-field reactive state
      form_signals.dart         # ValidasiFormSignals — form-wide reactive state
    models/
      field_state.dart          # ValidasiFieldState — data passed to field builders
      error.dart                # FieldError sealed hierarchy + FieldErrors
      validation_mode.dart      # ValidationMode, ReValidationMode enums
```

| Layer | Purpose |
|---|---|
| `controller/` | Business logic — field registration, validation, submit, lifecycle |
| `widgets/` | Flutter widgets — form scope, field binding, watch helpers |
| `signals/` | Reactive state containers built on `package:signals` |
| `models/` | Plain data classes, enums, sealed types — no side effects |

### Conventions

- **Package imports only** — use `package:validasi_ui/src/...` everywhere, never relative `../` paths.
- **`const` constructors** where possible.
- **No comments** unless the intent is genuinely unclear.
- **Follow `package:flutter_lints`** — run `dart run melos run analyze` before committing.
- **Widget files** are prefixed with `validasi_` (e.g. `validasi_form.dart`) to avoid name collisions with user code.
- **Sealed hierarchies** for error types — add a new subclass rather than adding flags.
- **Mixins** for optional controller capabilities (e.g. `WatchMixin`) — keeps the main class focused.

### Running locally

This package lives inside a Melos monorepo. Run commands from the **repo root**:

```bash
# Install dependencies
dart run melos bootstrap

# Run validasi_ui tests only
dart run melos run test:ui

# Run all tests
dart run melos run test

# Analyze all packages
dart run melos run analyze

# Fix formatting
dart run melos run format:fix
```

### Adding a new widget

1. Create `lib/src/widgets/validasi_<name>.dart`.
2. Import dependencies from sibling `src/` folders using package imports.
3. Export the new file from `lib/validasi_ui.dart`.
4. Add tests in `test/`.
5. Run `dart run melos run analyze && dart run melos run format:fix`.

### Adding a new signal or model

Same pattern — create the file in the appropriate `signals/` or `models/` subfolder, export it from the barrel, and add tests.

## License

MIT — see repository for details.
