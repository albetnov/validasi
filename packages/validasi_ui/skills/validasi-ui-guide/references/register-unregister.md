# Register / unregister mechanics

Two layers work together: an **immediate** layer that actually creates/disposes a field's signals,
and a **deferred, widget-presence** layer that decides *when* the immediate layer's unregister gets
called for a field whose widget unmounted. Understanding both explains behavior you'll otherwise
find surprising — like a field's value still being readable for one frame after you set
`show = false`.

## Layer 1 — immediate: `register` / `unregister` / `unregisterField`

`register<V>` (`controller.dart:208`) is idempotent — a no-op if the field is already registered —
and is called both explicitly and implicitly. Implicit auto-registration happens the first time
anything asks for a field's controller and it doesn't exist yet:

```dart
@override
ValidasiFieldSignals<V> getFieldController<V>(ValidasiField<T, V> field) {
  _throwIfDisposed();
  if (!_fields.containsKey(field)) {
    register(field);
  }
  return _fields[field] as ValidasiFieldSignals<V>;
}
```

This is why you almost never call `register` yourself: `getValue`, `setValue`,
`setFieldDisabled`, `validateField`, and every `ValidasiFormField`/`ValidasiWatchField` mount all
route through `getFieldController`, so a field springs into existence on first touch. (`setError`
is the one exception — see `gotchas.md`.)

`register` also wires two `signal.subscribe()` listeners (isDirty, touched) that keep the
form-level `isDirty`/`isTouched` aggregates in sync and call `notifyListeners()` on change. Those
subscriptions are why `unregisterField` (`controller.dart:246`) must explicitly tear them down
before disposing the field's signals — otherwise every register/unregister cycle would leak a
listener:

```dart
void unregisterField(ValidasiField<T, dynamic> field) {
  _asyncCoordinator.cancelField(field);
  final subs = _subscriptions.remove(field);
  if (subs != null) {
    for (final sub in subs) {
      sub();
    }
  }
  final fc = _fields.remove(field);
  fc?.dispose();
  _fieldsByName.remove(field.name);
  _arrayRegistry.onFieldUnregistered(field);
  if (!_disposed) {
    _formSignals.isDirty = _fields.values.any((f) => !f.disabled && f.isDirty.value);
    _formSignals.isTouched = _fields.values.any((f) => !f.disabled && f.touched);
  }
}
```

The sequence to remember: **cancel async validator → unsubscribe listeners → dispose the field's
signals → drop it from the name index → tell the array registry to drop its bookkeeping.**

`unregister<V>` (public, `controller.dart:266`) is the entry point a caller or the reconcile pass
actually calls — it also recursively unregisters array sub-fields via
`_arrayRegistry.unregisterSubFields`, then delegates to `unregisterField` for the field itself, then
syncs errors and notifies listeners. `unregisterField` alone is used internally (by `dispose()`'s
loop, and by the array registry for individual slot cleanup) precisely because it does *not*
recurse or notify — callers that already know they're handling recursion/notification themselves
use it directly.

## Layer 2 — deferred: widget presence and the post-frame reconcile

This layer implements `shouldUnregister` and exists for one reason: **a widget's `dispose()` runs
during Flutter's locked build phase, where calling `notifyListeners()` synchronously would crash**
(a `ListenableBuilder`/`SignalBuilder` still mounted above it would throw). So `unregister()` never
gets called directly from a widget's `dispose()` — instead, disposal is deferred to the next frame.

`_FormFieldState.dispose()` (`validasi_form_field.dart:40`) only does a pure data handoff:

```dart
@override
void dispose() {
  _controller?.removedFields.add(widget.field);
  super.dispose();
}
```

Every build, depending on `effectiveShouldUnregister` (`widget.shouldUnregister ??
ValidasiForm.shouldUnregisterOf<T>(context)`), the field either marks itself as currently tracked
or explicitly opts out:

```dart
if (!effectiveShouldUnregister) {
  controller.untrackField(widget.field);
  return child;
}
controller.markFieldTracked(widget.field);
```

`markFieldTracked` adds the field to both `_trackedFields` and `_presentThisFrame`, and schedules a
post-frame callback (idempotently — `_scheduleReconcile` no-ops if one's already pending):

```dart
void _scheduleReconcile() {
  if (_reconcileScheduled || _disposed) return;
  _reconcileScheduled = true;
  SchedulerBinding.instance.addPostFrameCallback((_) => _reconcilePresence());
}
```

`_reconcilePresence()` runs after the frame, comparing `removedFields` (widgets that disposed this
frame) against `_trackedFields`/`_presentThisFrame` (widgets that actually rebuilt this frame) to
tell a genuine removal apart from a same-frame recycle (e.g. a `ListView` reusing a slot, or a
rebuild that happens to dispose-then-remount the same field in one pass):

```dart
void _reconcilePresence() {
  _reconcileScheduled = false;
  if (_disposed) return;

  if (removedFields.isNotEmpty) {
    _isBatching = true;
    try {
      for (final f in removedFields.toList()) {
        if (_presentThisFrame.contains(f)) continue; // same-frame recycle — not a real removal
        if (_trackedFields.contains(f)) {
          unregister(f);
          _trackedFields.remove(f);
        }
      }
    } finally {
      _isBatching = false;
    }
    removedFields.clear();
    syncFieldErrors();
    notifyListeners();
  }

  _presentThisFrame.clear();
  if (_trackedFields.isNotEmpty) {
    _scheduleReconcile();
  }
}
```

Batching multiple simultaneous evictions means N fields disappearing in one frame produce exactly
one `notifyListeners()` call, not N. The `_disposed` check at the top makes this safe even if the
whole controller was disposed before the scheduled callback fires.

**What this means practically**: right after you flip a condition that unmounts a field (e.g.
`setState(() => _showExtra = false)`), the field's value is briefly still registered — it's only
actually unregistered on the *next* frame's reconcile pass. If you need the old value gone
synchronously, call `controller.unregister(field)` yourself instead of relying on unmount.

## `shouldUnregister` — the one knob you actually reach for

Default `false` (as of the `0.1.0-dev.4` breaking change — see `gotchas.md` for the still-wrong
README line this fixed): field state (`value`, `errors`, `dirty`, `touched`) **persists** across a
mount/unmount cycle. Set per-field via `ValidasiFormField.shouldUnregister`/`ValidasiTextField.
shouldUnregister`, which overrides the form-level default when non-null (`widget.shouldUnregister ??
ValidasiForm.shouldUnregisterOf<T>(context)`).

- **Leave it `false` (default)** for wizards/multi-step forms — a step's fields keep their values
  when the step unmounts (moving to the next page) and remounts (going back).
- **Set it `true`** on fields whose disappearance really should discard their value — e.g. a
  "same as billing address" toggle that reveals throwaway fields you don't want to resubmit if the
  toggle is flipped back and forth.
