# Controllers and signals reference

Everything in this package that holds mutable form/field state, mapped by who actually owns it.

```
ValidasiFormController<T>            (ChangeNotifier, public — you create/dispose this one)
 ├─ ValidasiFieldSignals<V>            per registered field, internal — the controller owns these
 ├─ ValidasiFormSignals                 form-wide state, internal — the controller owns this
 ├─ ValidasiArrayRegistry<T>            internal collaborator, never independently disposed
 ├─ ValidasiAsyncCoordinator<T>         internal collaborator, never independently disposed
 └─ ValidasiControllerContext<T>        private façade the two coordinators use to reach the controller

ValidasiTextController               (TextEditingController subclass, public — you may create/dispose it)
```

Only `ValidasiFormController` and `ValidasiTextController` are things you construct or dispose
yourself. Everything else in this file is plumbing the form controller manages internally —
useful to understand when debugging, never something to instantiate or dispose directly.

## `ValidasiFormController<T>` — `lib/src/controller/controller.dart`

```dart
ValidasiFormController({
  required ValidasiSchema<T> schema,
  FutureOr<ValidasiResult<T>> Function(ValidasiFormController<T>)? formValidator,
})
```

If `formValidator` is omitted and `schema` implements `ValidasiFormValidatorSchema<T>` (the
interface a `validasi_gen`-generated schema implements when `generateValidateForm` is on), the
generated cross-field validator is picked up automatically.

What it holds: a `Map<field, ValidasiFieldSignals>` and a name index, one `ValidasiFormSignals`,
one `ValidasiArrayRegistry`/`ValidasiAsyncCoordinator` (constructed eagerly in the constructor and
kept for the controller's whole life), a `Map<field, List<void Function()>>` of unsubscribe
callbacks for the isDirty/touched listeners set up in `register`, and the bookkeeping sets that
drive deferred unregistration (`_trackedFields`, `_presentThisFrame`, `removedFields` — see
`register-unregister.md`).

```dart
@override
void dispose() {
  _disposed = true;
  _trackedFields.clear();
  _presentThisFrame.clear();
  removedFields.clear();
  _reconcileScheduled = false;
  _asyncCoordinator.cancelAll();
  _arrayRegistry.clear();
  for (final field in _fields.keys.toList()) {
    unregisterField(field);
  }
  _formSignals.dispose();
  super.dispose();
}
```

Order matters: `_disposed = true` is set *first* so any reentrant calls triggered by the teardown
below short-circuit via the `_disposed`/`_throwIfDisposed()` guards that gate almost every public
member. Then pending async work is cancelled, array bookkeeping is cleared, every remaining field
is unregistered (which disposes its `ValidasiFieldSignals`), then the form-level signals are
disposed, then `super.dispose()` (`ChangeNotifier.dispose()`) runs last.

Virtually every public getter/method starts with `_throwIfDisposed()`:

```dart
void _throwIfDisposed() {
  if (_disposed) {
    throw StateError(
      'Cannot use a disposed ValidasiFormController. '
      'The form controller has been disposed and can no longer be accessed.',
    );
  }
}
```

`notifyListeners()` is overridden to no-op while disposed *or* while an internal batch operation
(`_isBatching`) is in progress — array operations and `setInitialValues` wrap multiple signal
writes in a batch so listeners see one coalesced notification instead of several.

## `ValidasiFieldSignals<V>` — `lib/src/signals/field_signals.dart`

The actual "field controller" — one per registered field, holding seven `package:signals` values
(`value`, `initialValue`, `errors`, `touched`, `disabled`, `isValidating`, `asyncError`) plus two
computed signals (`isDirty`, `isValid`). Constructed only by `ValidasiFormController.register` —
you never construct one yourself.

```dart
void dispose() {
  _disposed = true;
  _value.dispose();
  _initialValue.dispose();
  _errors.dispose();
  _touched.dispose();
  _disabled.dispose();
  _isValidating.dispose();
  _asyncError.dispose();
  isDirty.dispose();
  isValid.dispose();
}
```

Read accessors (`value`, `errors`, `syncErrors`, `isValidating`, `touched`, `disabled`) call
`_throwIfDisposed()`, which throws a message aimed squarely at the widget author, not just "this is
disposed":

```dart
'Field "${field.name}" was unregistered/evicted but a widget still '
'references its signal. The field may have been conditionally removed '
'from the widget tree. If this is intentional, ensure the referencing '
'widget is also removed/remounted when the field is evicted, or use '
'ValidasiWatch.form instead of ValidasiWatch.field for fields that '
'may be conditionally rendered.'
```

Mutators (the `value` setter, `updateErrors`, `isValidating` setter, `setAsyncError`,
`markTouched`, `setInitialValue`, `disabled` setter, `reset`, `migrateFrom`, `swapSignalsWith`)
instead silently `return` when disposed. This asymmetry is intentional: it lets an in-flight async
validator callback or a debounce `Timer` write to a field that got unregistered mid-flight without
crashing, while a widget that *reads* a stale reference still fails loudly and immediately.

## `ValidasiFormSignals` — `lib/src/signals/form_signals.dart`

Form-wide state: `isSubmitted`, `isLoading`, `isDirty`, `isTouched`, `fieldErrors`, `formErrors` —
six plain signals, no `_disposed` flag of its own (it relies on the owning controller's flag and is
only ever disposed once, from `ValidasiFormController.dispose()`).

## `ValidasiArrayRegistry<T>` — `lib/src/controller/array_registry.dart`

```dart
ValidasiArrayRegistry(ValidasiControllerContext<T> ctx, ValidasiFormController<T> controller)
```

Owns four bookkeeping maps describing array-item fields, their parent field, per-parent
object-array structures (index-to-sub-field callbacks for `appendArrayItem`/`insertArrayItem` with
`indexedFields`/`reconstructItem`/`reconstructAll`), and the list of sub-fields per array. It holds
no signals or subscriptions of its own — it registers/unregisters array-item fields through
`ValidasiControllerContext`, which is the same field-signal machinery as any other field. It has no
independent `dispose()`; instead the form controller calls `clear()` during its own `dispose()`:

```dart
void clear() {
  _objectArrayStructures.clear();
  _arraySubFields.clear();
}
```

`clear()` only drops bookkeeping — the array item *fields* themselves are cleaned up by the form
controller's own `unregisterField` loop over `_fields`, since array items are ordinary registered
fields.

## `ValidasiAsyncCoordinator<T>` — `lib/src/controller/async_coordinator.dart`

```dart
ValidasiAsyncCoordinator(ValidasiControllerContext<T> ctx)
```

Holds a `Map<field, _AsyncValidatorState>`, where each state has a nullable debounced `validator`,
a `Timer? debounceTimer`, and a `version` counter. No `dispose()` — lifecycle is `cancelAll()` (form
controller `dispose()`) and `cancelField(field)` (per-field `unregisterField`), both of which call:

```dart
void cancel() {
  debounceTimer?.cancel();
  version++;
}
```

Cancelling bumps `version` so that even a debounce `Timer` that had *already* fired before
cancellation raced in still discards its result — every completion checks `if (version !=
state.version) return;` before writing back to the field's signal. This is what makes it safe for
an async validator to finish after its field (or the whole form) has been torn down.

## `ValidasiControllerContext<T>` — `lib/src/controller/context.dart`

A private façade (`part of 'controller.dart'`) passed to the array registry and async coordinator
so neither ever reaches into `ValidasiFormController`'s private maps directly — only through
explicit methods (`register`, `unregisterField`, `fieldSignal`, `fieldByName`, `beginBatch`/
`endBatch`, `syncFieldErrors`, `notifyListeners`, `cancelAsyncField`, `migrateAsyncValidator`,
`triggerAsyncValidation`). You never see or construct this type — it's purely an internal seam that
keeps the two coordinators from being "independent controllers" with their own lifecycle; they're
collaborators of exactly one `ValidasiFormController`.

## `ValidasiTextController` — `lib/src/widgets/validasi_text_controller.dart`

```dart
class ValidasiTextController extends TextEditingController {
  ValidasiTextController({super.text});
}
```

A marker subclass with no extra lifecycle logic of its own — disposal is entirely governed by
whoever holds it: `ValidasiTextField` if it created one internally (see the ownership pattern in
`SKILL.md`), or the caller if they passed one in.
