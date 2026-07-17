# Claude Code Skills

This repository ships three [Claude Code Agent Skills](https://code.claude.com/docs/en/skills) —
curated, always-loadable references that shape how Claude writes `validasi` code, rather than a
tool Claude has to go looking for. They live in this repo's `skills/` directory, one per package,
mirroring the same split as the rest of these docs.

## Why skills, not just docs

The pages in this site are for you to read. Skills are for Claude to read — each one is a compact
`SKILL.md` (plus deeper `references/*.md` files for less-common detail) written specifically to
steer an AI assistant toward the correct API shape, the right rule/annotation to reach for, and the
lifecycle rules (disposal, registration, async validation) that are easy to get subtly wrong from
first principles. Where this site explains *why* something works the way it does, a skill is
optimized to make Claude *do* the right thing by default, on the first attempt, without you having
to paste in explanations.

## The three skills

| Skill | Covers | Companion section |
|-------|--------|-------------------|
| `validasi` | Building schemas, `Rules.*`, transforms vs. preprocessing, custom sync/async rules, error handling | Core `validasi` |
| `validasi-gen` | `@ValidateClass`/`@Validate<T>` annotations, build flags and their gating rules, `@RefineFn`/cross-field sugar, extensibility (`Inline`, `CustomRule`, etc.) | [Code Generation](/companion/generator/overview) |
| `validasi-ui` | `ValidasiFormController` ownership/disposal, register/unregister and `shouldUnregister`, `ValidasiSubmit`'s sync/async paths, common lifecycle footguns | [Form Management](/companion/form-management/overview) |

Each skill's description is written to trigger even when you don't name the package explicitly —
e.g. asking Claude to "validate this form field" or "why does my controller throw after dispose"
is enough for the right skill to load.

## Using them in this repo

If you're working inside this monorepo with Claude Code, nothing to set up — skills under
`skills/` are discovered automatically and trigger based on their description whenever a task
matches (writing a schema, wiring a form, debugging a codegen build). You can also invoke one
explicitly with `/validasi`, `/validasi-gen`, or `/validasi-ui`.

## Using them in your own project

Claude Code loads project-level skills from a `.claude/skills/` directory. To get the same
guidance while working on your own app:

1. Copy the relevant skill folder(s) — e.g. `skills/validasi-ui/` — from this repository into
   your project's `.claude/skills/` directory.
2. Keep the folder name and internal structure (`SKILL.md` plus its `references/` subfolder)
   intact; Claude Code reads the whole folder as one unit.
3. That's it — the next time you ask Claude Code to do something the skill's description covers,
   it loads automatically.

You only need the skill(s) matching the packages you actually use — `validasi-ui`'s skill isn't
useful in a backend-only project with no Flutter forms, for instance.

## Skills vs. the MCP server

These solve different problems, and you can use either or both:

- **[MCP server](/companion/mcp-server)** (`validasi_mcp`) is a *lookup tool* — Claude calls it at
  runtime to search or fetch this docs site when it needs to look something up. Useful for
  anything not baked into a skill, or for keeping up with docs changes without updating a skill.
- **Skills** are *authored guidance* — they're already loaded before Claude writes a line of code,
  encoding the lifecycle rules, gotchas, and "reach for X, not Y" decisions that are tedious to
  re-derive from a documentation lookup every time.

Using both means Claude starts from the skill's curated judgment and can still fall back to the
MCP server for anything the skill doesn't cover.
