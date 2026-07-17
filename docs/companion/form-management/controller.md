# Controller & Signals

`ValidasiFormController<T>` is the state manager for a `ValidasiForm<T>`. It holds
field values, errors, dirty/touched state, and runs validation. It implements
`ValidasiFieldReader<T>`, making it directly usable as a schema allocator source.

## Getting the controller

```dart
// From a widget inside ValidasiForm<T>
final controller = ValidasiForm.of<User>(context);

// Create your own (pass to ValidasiForm via `controller:` param)
final controller = ValidasiFormController(schema: UserFields.schema);
```

## State

| Getter | Type | Description |
|--------|------|-------------|
| `isSubmitted` | `bool` | True after first submit attempt |
| `isLoading` | `bool` | Async validation in progress |
| `isDirty` | `bool` | Any field has changed from initial |
| `isPristine` | `bool` | No field has changed |
| `isTouched` | `bool` | Any field has been interacted with |
| `isValid` | `bool` | All non-disabled fields are valid |
| `fieldErrors` | `List<FieldErrors>` | All per-field errors |
| `formErrors` | `List<ValidationError>` | Form-level errors (from refines / form validator) |

## Values

```dart
// Read a single field value
final name = controller.getValue(UserFields.name);  // String?

// Write a single field value
controller.setValue(UserFields.email, 'new@email.com');

// Read all field values
final values = controller.getValues();
// Map<ValidasiField<User, dynamic>, dynamic>
```

## Validation

```dart
// Sync: validates all fields + cross-field rules
final isValid = controller.validate();   // bool

// Async: validates all fields (sync + async rules) + cross-field
final isValid = await controller.validateAsync();   // bool

// Validate a single field (sync)
controller.validateField(UserFields.email);

// Validate a single field, awaiting its async rules too (falls back to the
// whole-form validator if one is set, since cross-field rules may depend on it)
await controller.validateFieldAsync(UserFields.email);

// Trigger async validation on a field (debounced)
await controller.triggerAsyncValidation(UserFields.email);
```

## Error management

```dart
// Read errors for a field
final errors = controller.getErrors(UserFields.email);
// List<FieldError>

// Set an error programmatically
controller.setError(UserFields.email, 'Custom error message',
    rule: 'Custom', overwrite: true);

// Clear a field's errors
controller.clearErrors(UserFields.email);

// Clear all errors
controller.clearAllErrors();
```

## Submit

```dart
// Sync submit — validates, then calls onSubmit(allocated model)
final onTap = controller.submit((user) {
  saveUser(user);
});

// Async submit
Future<void> Function() onTap = controller.submitAsync((user) async {
  await saveUser(user);
  if (context.mounted) Navigator.pop(context);
});
```

## Reset & initial values

```dart
// Set initial values from a model (marks all fields as pristine)
controller.setInitialValues(existingUser);

// Reset to initial values, clear errors, clear touched
controller.reset();
```

## Dirty / touched per field

```dart
controller.isFieldDirty(UserFields.name);
controller.isFieldTouched(UserFields.name);
```

## Field lifecycle

```dart
// Disable a field (skip validation, clear errors)
controller.setFieldDisabled(UserFields.age, true);

// Re-enable
controller.setFieldDisabled(UserFields.age, false);
```

Fields auto-register via `ValidasiFormField` / `ValidasiTextField` widgets.
When `shouldUnregister: false` (default), field state persists across mount/unmount.
Set `shouldUnregister: true` on `ValidasiForm` or per-field to auto-unregister.

## Async validators (inline)

Register async validation without touching the model's annotations:

```dart
controller.setFieldValidator(
  UserFields.email,
  (email) async {
    if (email == null || email.isEmpty) return null;
    final taken = await checkEmailTaken(email);
    return taken ? 'Email already taken' : null;
  },
  debounce: const Duration(milliseconds: 500),
);
```

Return `null` for valid, a `String` error message for invalid. The validator is
debounced and uses a version counter to discard stale results.

## Field arrays

```dart
// Append an item to a list field
controller.appendArrayItem(UserFields.tags, 'new-tag');

// Insert at index
controller.insertArrayItem(UserFields.tags, 0, 'first-tag');

// Remove at index
controller.removeArrayItem(UserFields.tags, 2);

// Swap two items
controller.swapArrayItems(UserFields.tags, 0, 1);

// Get array item count
final count = controller.getArrayItemCount(UserFields.tags);

// Get a specific item's field
final itemField = controller.getArrayItemField(UserFields.tags, 0);
```

For object arrays (nested `@ValidateClass`), use `generateIndexedFields: true` in your build
options — for a `List<Car> previousCars` field, that generates `indexedFields<FormType>`,
`reconstructItem<FormType>`, and `reconstructAll<FormType>` static methods on `CarFields` (the
generated fields class for the nested `Car` model). Wrap them in closures binding the parent
field/path when passing them to `appendArrayItem`/`insertArrayItem`, so the controller knows how
to create and reconstruct each row's sub-fields:

```dart
controller.appendArrayItem(
  UserFields.previousCars,
  newCar,
  indexedFields: (index) => CarFields.indexedFields<User>('previousCars', index),
  reconstructItem: (ctrl, index) =>
      CarFields.reconstructItem<User>(ctrl, UserFields.previousCars, index),
  reconstructAll: (ctrl) => CarFields.reconstructAll<User>(ctrl, UserFields.previousCars),
);

// Access a nested object's field
final nestedField = controller.getArraySubField(
    UserFields.previousCars, 0, 'model');
```

## Signals (reactivity)

Each field is backed by a `ValidasiFieldSignals<V>` instance, which holds reactive
signals for the value, errors, dirty, touched, disabled, and isValidating flags.

```dart
final signals = controller.getFieldController(UserFields.name);
// ValidasiFieldSignals<String>

signals.value;                    // current value
signals.valueSignal;              // ReadonlySignal<String?> (for SignalBuilder)
signals.errors;                   // syncErrors + asyncError
signals.isValidating;
signals.isDirty;                  // ReadonlySignal<bool>
signals.isValid;                  // ReadonlySignal<bool>
signals.touched;
signals.disabled;
```

You rarely need to access signals directly — `ValidasiFormField` and
`ValidasiWatch` consume them internally. Use them for custom widget bindings.

## Watching values without a widget

`ValidasiFormController<T>` mixes in `WatchMixin<T>`, which exposes two helpers returning
`package:signals` readonly signals — read them inside a `SignalBuilder`/`Watch` you already
control, or anywhere else you'd read a signal's `.value`:

```dart
// One field's value as a signal
final emailSignal = controller.watchValue<String>(UserFields.email); // ReadonlySignal<String?>

// Derive a value from several same-typed fields — selector gets a Map keyed by field
final fullNameSignal = controller.watch<String, String>(
  [UserFields.firstName, UserFields.lastName],
  (values) => '${values[UserFields.firstName] ?? ''} ${values[UserFields.lastName] ?? ''}',
); // ReadonlySignal<String>
```

Prefer `ValidasiWatch.field`/`ValidasiWatch.form` for widget trees — reach for `watchValue`/`watch`
when you need the underlying signal somewhere `ValidasiWatch` doesn't fit naturally (e.g. composing
it into another `computed`).

## Disposal

```dart
controller.dispose();   // call if you created the controller manually
```

Controllers auto-created by `ValidasiForm` are disposed automatically.
Manually created controllers must be disposed explicitly.
