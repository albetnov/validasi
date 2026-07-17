# Widgets Reference

## `ValidasiForm<T>`

The root form widget. Creates and scopes a `ValidasiFormController<T>` via `InheritedWidget`.
`T` is inferred from the `schema` **or** `controller` argument.

```dart
ValidasiForm(
  schema: UserFields.schema,       // omit when you pass your own `controller`
  mode: ValidationMode.onSubmit,
  reValidateMode: ReValidationMode.onChange,
  initialValues: null,
  shouldUnregister: false,
  controller: myController,       // optional — pass your own (then drop `schema`)
  formValidator: myFormValidator,  // optional — custom form-level validation
  builder: (context, submit) {
    // `submit` is a ValidasiSubmit<T> — a callable class, not a plain function type.
    //
    // Sync usage:
    //   submit((user) { saveUser(user); })
    //
    // Async usage (validates async rules too):
    //   submit.async((user) async { await saveUser(user); })
    //
    // submit(...) returns a VoidCallback; submit.async(...) returns a
    // Future<void> Function().
    return YourFormContent(submit: submit);
  },
);
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `schema` | `ValidasiSchema<T>?` | `null` | Builds model from controller on submit. Provide this **or** a `controller` (at least one required); omit it when you pass your own controller |
| `builder` | `Widget Function(BuildContext, ValidasiSubmit<T>)` | required | Your form UI |
| `controller` | `ValidasiFormController<T>?` | `null` | External controller (form auto-creates one from `schema` if not provided). Provide this **or** a `schema` |
| `formValidator` | `FutureOr<ValidasiResult<T>> Function(ValidasiFormController<T>)?` | `null` | Custom form-level validation (runs after all field validation) |
| `mode` | `ValidationMode` | `onSubmit` | When fields first validate |
| `reValidateMode` | `ReValidationMode` | `onChange` | How fields re-validate after first validation |
| `initialValues` | `T?` | `null` | Seed initial values for all registered fields |
| `shouldUnregister` | `bool` | `false` | Preserve field state (value, errors, dirty/touched) across mount/unmount cycles. Set to `true` to auto-unregister on widget unmount |

### Static helpers

```dart
// Get the controller from any descendant
final controller = ValidasiForm.of<User>(context);

// Get validation modes from the scope
final (mode, reMode) = ValidasiForm.modeOf<User>(context);

// Get unregister setting
final unregister = ValidasiForm.shouldUnregisterOf<User>(context);
```

## `ValidasiFormField<T, V>`

Binds a `ValidasiField<T, V>` to a builder function. `T` and `V` are inferred
from the `field` argument. Rebuilds only when its own
signals change (fine-grained reactivity).

```dart
ValidasiFormField(
  field: UserFields.name,
  mode: null,                    // override form's ValidationMode
  reValidateMode: null,          // override form's ReValidationMode
  disabled: false,
  validator: myAsyncValidator,   // optional inline async validator
  debounceDuration: const Duration(milliseconds: 300),
  shouldUnregister: null,        // override form's shouldUnregister
  builder: (context, state) {
    // state: ValidasiFieldState<String>
    //   state.value         — V?       (current field value)
    //   state.onChanged     — void Function(V?)  (set value)
    //   state.onFocusChange — void Function(bool)?  (blur detection)
    //   state.errorText     — String?  (first error message)
    //   state.hasError      — bool
    //   state.isDirty       — bool
    //   state.isPristine    — bool  (!isDirty)
    //   state.isTouched     — bool
    //   state.isValidating  — bool
    //   state.disabled      — bool
    //   state.setError      — void Function(String, {bool overwrite})
    //   state.clearErrors   — void Function()
    //   state.validate      — void Function()
    return TextField(
      onChanged: state.onChanged,
      decoration: InputDecoration(
        labelText: 'Name',
        errorText: state.errorText,
      ),
    );
  },
);
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `field` | `ValidasiField<T, V>` | required | Field key to bind |
| `builder` | `Widget Function(BuildContext, ValidasiFieldState<V>)` | required | Your field UI |
| `mode` | `ValidationMode?` | `null` | Per-field override of form mode |
| `reValidateMode` | `ReValidationMode?` | `null` | Per-field override of form revalidation |
| `disabled` | `bool` | `false` | Skip validation, clear errors |
| `validator` | `Future<String?> Function(V?)?` | `null` | Inline async validator (returns error string or null) |
| `debounceDuration` | `Duration` | `300ms` | Debounce async validation |
| `shouldUnregister` | `bool?` | `null` | Per-field override of form shouldUnregister |

## `ValidasiTextField<T, V>`

Convenience wrapper: `ValidasiFormField` + automatic `TextEditingController` management.
Replaces the removed `ValidasiTextFormField` and `ValidasiParsedTextFormField`.
`T` and `V` are inferred from the `field` argument.

```dart
ValidasiTextField(
  field: UserFields.name,
  controller: myController,     // optional — auto-creates one if not provided
  builder: (context, state, controller) {
    // controller is a ValidasiTextController (extends TextEditingController)
    return TextField(
      controller: controller,   // pass directly to TextField
      decoration: InputDecoration(
        labelText: 'Name',
        errorText: state.errorText,
        suffixIcon: state.isValidating
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ),
    );
  },
);
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `field` | `ValidasiField<T, V>` | required | Field key to bind |
| `builder` | `Widget Function(BuildContext, ValidasiFieldState<V>, ValidasiTextController)` | required | Builds your text field UI |
| `controller` | `ValidasiTextController?` | `null` | External controller for programmatic control |
| `mode`, `reValidateMode`, `disabled`, `validator`, `debounceDuration`, `shouldUnregister` | _(same as ValidasiFormField)_ | | |

The widget handles:
- Creating a `ValidasiTextController` if none provided
- Syncing form value → controller text on every build (not conditional on `initialValues`)
- Syncing controller text → form value (when user types)
- Disposing the controller on unmount, but **only if it created it** — if you pass your own
  `controller:`, you own it and must dispose it yourself

## `ValidasiTextController`

A trivial `TextEditingController` subclass for use with `ValidasiTextField`.

```dart
final controller = ValidasiTextController(text: 'initial text');

ValidasiTextField(
  field: UserFields.name,
  controller: controller,
  builder: (context, state, ctrl) => TextField(controller: ctrl),
);

// Programmatic control
controller.text = 'new value';
controller.clear();
controller.selection = TextSelection.collapsed(offset: 3);
```

Use it when you need to read/control the text value from outside the widget.

## `ValidasiWatch`

Lightweight reactive watchers that rebuild when signals change. Use inside a `ValidasiForm` scope.

### Watch the form controller

When no `controller` is passed, `T` must be explicit (it can't be inferred from a builder closure alone). Pass `controller:` to avoid the explicit generic:

```dart
ValidasiWatch.form<User>(
  controller: myController,          // optional — when passed, <T> is inferred
  builder: (context, controller) {
    return Text('Form valid: ${controller.isValid}');
  },
);
```

Rebuilds whenever the controller notifies (dirty, touched, errors change).

### Watch a field value

```dart
ValidasiWatch.field(
  field: UserFields.name,
  builder: (context, value) {
    return Text('Name length: ${value?.length ?? 0}');
  },
);
```

Rebuilds only when that field's value changes.

## `ValidasiSubmit<T>`

The type of the `submit` parameter in `ValidasiForm.builder`. It's a small callable class, not a
plain function type — it has two entry points:

```dart
class ValidasiSubmit<T> {
  VoidCallback call(void Function(T) onSubmit);              // sync: controller.submit(...)
  Future<void> Function() async(void Function(T) onSubmit);  // async: controller.submitAsync(...)
}
```

- `submit(onSubmit)` — calling the object directly (Dart lets a class with a `call()` method be
  invoked like a function) runs sync `validate()`, then calls `onSubmit` with the built model if
  valid.
- `submit.async(onSubmit)` — runs `validateAsync()` instead, which awaits any async rules
  (`AsyncInline`, `AsyncCustomRule`, an async `@RefineFn`) before calling `onSubmit`.

**Use `submit.async(...)` if the form has any async validation at all.** The sync `submit(...)`
path throws `StateError` the moment it hits a field with an async rule — see
[With Codegen](/companion/form-management/with-codegen) for the exact failure mode.

```dart
builder: (context, submit) {
  return ElevatedButton(
    onPressed: submit((user) => saveUser(user)), // sync form — no async rules
    child: const Text('Submit'),
  );
}
```

For a form with async validation:

```dart
builder: (context, submit) {
  return ElevatedButton(
    onPressed: submit.async((user) async {
      await saveUser(user);
      if (context.mounted) Navigator.pop(context);
    }),
    child: const Text('Submit'),
  );
}
```
