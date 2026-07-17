---
name: validasi-ui
description: >-
  Wire validasi schemas into Flutter forms with validasi_ui — ValidasiForm, ValidasiFormField,
  ValidasiTextField, ValidasiWatch, and the ValidasiFormController that backs them. Use this
  whenever the user builds or wires a Flutter form with validasi, decides whether to create or
  pass in a ValidasiFormController/ValidasiTextController, needs to know when a controller gets
  disposed, asks about fields not clearing on unmount (or clearing when they shouldn't — the
  shouldUnregister option), builds a multi-step/wizard form that must preserve values across
  steps, sees a "Cannot use a disposed ValidasiFormController" or "was unregistered/evicted"
  StateError, wires debounced async field validators, or works with array/list fields
  (appendArrayItem/removeArrayItem/swapArrayItems). Reach for this skill whenever
  ValidasiFormController, ValidasiForm, ValidasiFormField, ValidasiTextField, ValidasiWatch,
  ValidasiTextController, or validasi_ui appears in the code or request, even if the user
  doesn't name the package explicitly.
---

# Validasi UI

`validasi_ui` is headless Flutter form management on top of `validasi`: a `ValidasiFormController<T>`
holds per-field reactive state (via `package:signals`) and validates it against a `ValidasiSchema<T>`,
while `ValidasiForm`/`ValidasiFormField`/`ValidasiTextField`/`ValidasiWatch` wire that controller into
widgets. This skill is the curated, always-in-context reference for the lifecycle decisions —
who creates a controller, who disposes it, and what `shouldUnregister` actually does — that this
package hands you as explicit, learnable choices instead of hiding them. Deep catalogs live in
`references/`.

## Imports & orientation

```dart
import 'package:validasi/validasi.dart';   // ValidasiSchema, ValidasiResult
import 'package:validasi_ui/validasi_ui.dart'; // ValidasiForm, ValidasiFormController, ...
```

A `ValidasiFormController<T>` is a `ChangeNotifier` — it holds one `ValidasiFieldSignals` per
registered field, plus form-wide signals (`isSubmitted`, `isLoading`, `isDirty`, `isTouched`,
`fieldErrors`, `formErrors`). Widgets never touch these signals directly; they go through the
controller (`getValue`, `setValue`, `getErrors`, `validate()`/`validateAsync()`, `submit(...)`).
Full class-by-class breakdown (including the internal array/async coordinators the controller
delegates to): `references/controllers.md`.

## Who owns the controller

Every widget in this package that can hold a controller follows the same rule: **`widget.controller
?? Controller()` in `initState` — and only the side that created it disposes it.**

```dart
// ValidasiForm — the common case: no controller passed, so ValidasiForm owns and disposes it.
ValidasiForm<User>(
  schema: UserFields.schema,
  builder: (context, submit) => Column(children: [
    ValidasiTextField(field: UserFields.email, builder: (ctx, state, ctrl) => TextField(
      controller: ctrl,
      onChanged: state.onChanged,
    )),
    ElevatedButton(onPressed: submit(saveUser), child: const Text('Save')),
  ]),
)
```

```dart
// You own it: pass a controller in, and YOU must dispose it — ValidasiForm won't.
class _MyPageState extends State<MyPage> {
  final _controller = ValidasiFormController<User>(schema: UserFields.schema);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValidasiForm<User>(
    controller: _controller,
    // no `schema:` — the controller already holds it.
    builder: (context, submit) => /* ... */,
  );
}
```

Reach for the "I own it" form when something outside the form's own subtree needs to read or
drive the controller — an app-bar save button, a sibling summary panel, a wizard's shared
page-controller. Otherwise let the widget own it; it's one less disposal to get wrong.

The same rule applies to `ValidasiTextField`'s `controller` (a `ValidasiTextController`, a thin
`TextEditingController` subclass): omit it and the field creates + disposes its own; pass one in
(e.g. because you need `.text` from outside the builder) and you own its `dispose()`.

**Never dispose a controller you didn't create.** If you pass `controller:` into `ValidasiForm` or
`ValidasiTextField`, that widget will *not* dispose it for you — and if you *also* call
`.dispose()` on it yourself from the wrong place (e.g. a widget that merely consumes it), any other
consumer that touches it afterwards throws `StateError` (see below). Ownership is single and
explicit — trace it to exactly one `initState`/constructor before deciding who calls `dispose()`.

## Fields register themselves — you rarely call `register`/`unregister` directly

A field registers itself the first time anything asks the controller for its state (`getValue`,
`setValue`, or a `ValidasiFormField` mounting) — there's no explicit "declare all fields upfront"
step. Unregistering on unmount is *deferred* to a post-frame reconcile pass (so it never fires
`notifyListeners()` mid-build), which is why a field's value is briefly still readable right after
you set `show = false` but before the next frame. The mechanics are in
`references/register-unregister.md` — day to day, the only thing you actually decide is:

**`shouldUnregister`** (on `ValidasiForm`, overridable per-`ValidasiFormField`): defaults to
`false` — a field's value/errors/dirty/touched state **persists** across mount/unmount. Set it to
`true` when a field disappearing really should reset it (e.g. a "different shipping address"
toggle that reveals throwaway fields). Leave it `false` (the default) for wizards / multi-step
forms where a later step's field must still hold its value when an earlier step remounts it.

## Disposal rules & symptoms

- **Own it → dispose it.** Whichever `initState`/constructor created the controller (because the
  caller passed none) is the only place that should call `.dispose()`.
- **After `dispose()`, every controller method throws `StateError`** — "Cannot use a disposed
  ValidasiFormController" — not a silent no-op. Treat this as a bug signal: something held a
  reference past its owner's lifetime.
- **A widget that still reads a field's signal after that field was unregistered/evicted** gets a
  different `StateError`, whose message tells you the fix directly: remount the referencing widget
  along with the field, or use `ValidasiWatch.form` instead of `ValidasiWatch.field` for fields
  that may be conditionally rendered.
- Getters throw when disposed; setters/mutators quietly no-op. That asymmetry is deliberate — it
  lets an in-flight async validator's debounce `Timer` (or an already-scheduled callback) safely
  write to a disposed field without crashing, while a stale *read* from a lingering widget still
  fails loudly. Full list of these footguns, with the exact error text and fix for each:
  `references/gotchas.md`.

## Quick reference

| Task | Approach |
|------|----------|
| Simple form, no external control needed | `ValidasiForm(schema: ..., builder: ...)` with no `controller:` — it owns and disposes it |
| Need to submit/reset from outside the form's builder | Create + hold `ValidasiFormController` yourself, pass it in (drop `schema:` on the form — the controller holds it), dispose it in your own `dispose()` |
| Text field needs an externally-readable `.text` | Create + hold a `ValidasiTextController`, pass it in, dispose it yourself |
| Wizard/multi-step form — keep values across steps | Leave `shouldUnregister: false` (the default) |
| A conditional field should reset when hidden | `shouldUnregister: true` on that `ValidasiFormField` (or form-wide) |
| Field rebuilds even though it's not mounted in the tree anymore | Check whether an ancestor still watches it with `ValidasiWatch.field` instead of `ValidasiWatch.form` |
| Debounced async validator (e.g. uniqueness check) | `controller.setFieldValidator(field, validator, debounce: ...)` — cancellation/version-guarding is automatic on unregister |
| List-backed fields (add/remove/reorder rows) | `appendArrayItem`/`insertArrayItem`/`removeArrayItem`/`swapArrayItems` — signal migration between slots is handled for you |
| "Cannot use a disposed ValidasiFormController" | Something used the controller after its owner disposed it — trace ownership, don't just suppress the error |

## Companion references

- `references/controllers.md` — every controller/signals class (`ValidasiFormController`,
  `ValidasiFieldSignals`, `ValidasiFormSignals`, `ValidasiTextController`, and the internal
  `ValidasiArrayRegistry`/`ValidasiAsyncCoordinator` coordinators), what each holds, and their
  `dispose()` bodies.
- `references/register-unregister.md` — the two-layer register/unregister mechanism in full:
  immediate map mutation vs. deferred post-frame reconcile, and why the split exists.
- `references/gotchas.md` — footguns as a scannable list: disposed-controller/disposed-field
  errors, the `setValue` auto-register vs. `setError` silent-no-op asymmetry, async debounce +
  version guarding, and the `shouldUnregister` default that the package's own README used to
  document incorrectly.

See `validasi` for the schema/rules layer these controllers validate against (`Validasi.*`,
`Rules.*`, `ValidasiResult`), and `validasi-gen` if fields come from `@ValidateClass`-annotated
models (`generateValidateForm`/`generateIndexedFields` build flags target this package directly).
