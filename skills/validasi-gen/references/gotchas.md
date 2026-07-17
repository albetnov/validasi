# Gotchas

Behaviors that are easy to be surprised by — read this when debugging a generated validator that
isn't behaving as expected.

## Unregistered/typo'd rules are silently dropped

If a rule name in `@Validate<T>([...])` doesn't match any registered handler (a typo, or a rule
type the generator genuinely doesn't know about), the parser records it internally as an "unknown"
rule and **moves on without emitting any check and without raising a build error**. The field
compiles, `build_runner` succeeds, and the resulting `validate()` simply never rejects the value
you expected it to catch. This is the most dangerous failure mode in this package precisely because
nothing surfaces it — if a validator seems to be silently accepting bad input, first suspect a
misspelled or unsupported rule in its `@Validate<T>([...])` list before assuming a logic bug
elsewhere.

## Nested `@ValidateClass` fields

- A field typed as another `@ValidateClass`-annotated class gets its `.validate()`/`.validateAsync()`
  called automatically, with error paths prefixed by the field name (`['car', 'make']`).
- A **nullable** nested field (`Car?`) is skipped entirely when `null` — no error, no recursive call.
- A `List<NestedType>` iterates with index-prefixed paths (`['previousCars', '0', 'make']`).
- A `Map`-typed field is **never** treated as nested, even if its value type is `@ValidateClass`-
  annotated — map values don't get the automatic nested-validation treatment.
- A dependency cycle between `@ValidateClass` types (A nests B, B nests A) is a **build-time error**
  (`InvalidGenerationSourceError` naming the cycle), not a runtime stack overflow.

## Name-collision suffixing

A field literally named `name`, `extract`, `validate`, or `validateAsync` would collide with an
instance member of the same name that the generated `XFields` hierarchy requires — a class can't
declare both a static and an instance member sharing a name. The generator dodges this by
suffixing the generated static accessor with an underscore (`UserFields.name_` instead of
`UserFields.name`). This only affects the generated accessor identifier; the field's own runtime
`.name` getter still reports the real, unsuffixed name. If a static accessor lookup for an
obviously-named field doesn't compile, check whether it's one of these four reserved names.

## Regenerate after any annotation change

Because `.g.dart` is a checked-in-adjacent generated `part` file, editing an annotation
(`@Validate<T>([...])`, `@ValidateClass(...)`, a `@RefineFn`, adding a field) has no effect until
you rerun the build:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Prefer `--delete-conflicting-outputs` over debugging stale build errors — a renamed or removed
field can leave an orphaned `.g.dart` output that the builder refuses to overwrite silently.

## Docs vs. source

The package's `README.md` and `ARCH.md` are behind the actual generator — most notably they
describe a `generateAssemble` build flag and `assemble_X(...)` generated function that no longer
exist (superseded by `generateSchema` / `XFields.schema`), and omit `generateIndexedFields`
entirely. When flag names or generated-code shape in the docs disagree with what you observe from a
build, trust the build output and `lib/src/builder.dart` over the prose.
