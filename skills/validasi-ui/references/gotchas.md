# Gotchas

Concrete symptom → cause → fix, for the lifecycle footguns this package guards against.

## "Cannot use a disposed ValidasiFormController"

**Symptom**: `StateError` thrown from almost any controller call — `getValue`, `setValue`,
`validate()`, a getter, etc.

**Cause**: something called the controller after its owner disposed it. Every public member starts
with `_throwIfDisposed()`, which throws instead of silently no-oping — this is a loud "you have a
bug" signal, not a recoverable state.

**Fix**: trace which widget/object created this controller (`widget.controller ?? Controller()`)
and confirm nothing outside that owner's lifetime still holds a reference to it — e.g. a callback
captured in a closure that outlives the widget, or a controller passed to a second widget that
also (wrongly) disposes it. Only the creator disposes it; see "Who owns the controller" in
`SKILL.md`.

## "Field \"x\" was unregistered/evicted but a widget still references its signal"

**Symptom**: `StateError` thrown from a `ValidasiFieldSignals` getter (`value`, `errors`,
`isValidating`, `touched`, `disabled`).

**Cause**: a widget still reads a field's signal after that field's `ValidasiFieldSignals` was
disposed — typically because an *ancestor* is watching the field with `ValidasiWatch.field` while
the field itself is conditionally rendered and gets unregistered, but the ancestor doesn't unmount
along with it.

**Fix**: the error message names both options — either make sure the referencing widget unmounts/
remounts together with the field, or switch that ancestor from `ValidasiWatch.field` to
`ValidasiWatch.form` (which rebuilds from the whole controller instead of holding a per-field
signal reference that can go stale).

## `setValue`/`setFieldDisabled`/`validateField` silently auto-register; `setError` does not

**Symptom**: calling `controller.setValue(field, x)` on a field you never explicitly registered
"just works" (it gets created on the spot), but `controller.setError(field, 'message')` on an
unregistered field does nothing — no error, no exception, no effect.

**Cause**: `setValue`/`setFieldDisabled`/`validateField` all route through `getFieldController`,
which auto-registers on first use. `setError` instead looks the field up directly in `_fields` and
bails if it's `null` — there's no sensible value/initial-value to manufacture a field state from
just an error message, so it can't auto-register the way the others can.

**Fix**: if you need `setError` to work, make sure the field is registered first (mount its
`ValidasiFormField`/`ValidasiTextField`, or call `getValue`/`setValue` on it once) before calling
`setError`.

## Getters throw after disposal; setters/mutators silently no-op

**Symptom**: reading a disposed field's `.value` throws, but writing to it (e.g. from an in-flight
async validator callback) does nothing instead of throwing.

**Cause**: deliberate asymmetry. An async validator's debounce `Timer` or a not-yet-awaited
callback can legitimately still be "in flight" when its field gets unregistered mid-interaction
(user navigated away, field got conditionally removed) — those callbacks need to finish without
crashing, so mutators just no-op when `_disposed`. A widget *reading* a stale signal, on the other
hand, almost always indicates a real bug (see the previous two gotchas), so getters fail loudly.

**Fix**: don't work around this by wrapping reads in try/catch — if you're hitting the getter-side
`StateError`, that's the signal to fix the widget/controller lifetime, not to suppress the error.

## Async validator debounce + version guard

**Symptom**: you'd expect an in-flight debounced async validator to sometimes write stale results
to a field after it's been unregistered or the whole form disposed — but it doesn't.

**Cause**: `cancelField`/`cancelAll` call `_AsyncValidatorState.cancel()`, which cancels the pending
`Timer` *and* bumps a `version` counter. Every async completion checks `if (version !=
state.version) return;` before writing anything back — so even a timer that had already fired
*before* the cancel raced in still discards its result once it notices the version moved.

**Fix**: nothing to do — this is handled for you. It's worth knowing about so you don't add your
own defensive cancellation/guarding on top when wiring `setFieldValidator`.

## The package's own README used to document the wrong `shouldUnregister` default

**Context, not a live bug**: `shouldUnregister`'s default flipped from `true` to `false` in the
`0.1.0-dev.4` changelog entry ("Field state ... now persists across mount/unmount cycles by
default"), but `README.md`'s `ValidasiForm` options table kept describing the old (`true`) default
until this skill's authoring pass corrected it. If you're ever unsure which default is live for a
behavior like this, `validasi_form.dart`'s constructor (`this.shouldUnregister = false`) and the
CHANGELOG are the source of truth — a README can lag a breaking change.
