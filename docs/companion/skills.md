# Agent Skills

Each package ships its own [Agent Skills](https://agentskills.io) — curated, always-loadable
references that shape how an AI coding agent writes `validasi` code, rather than a tool it has to
go looking for. The skills live next to the package's `lib/` directory, so `dart run skills@ get`
can discover and install them from your dependency tree.

The repository also keeps a mirror in the top-level `skills/` directory for the older
`npx skills` installer. That mirror is maintained for compatibility; new projects should use the
Dart installer.

Every package README carries an **AI Agents** section pointing back here, so an agent that only
sees a package README — on pub.dev, say — still finds the matching skill.

**They aren't Claude Code–specific.** `SKILL.md` is an open format — YAML frontmatter (`name`,
`description`) plus a Markdown body, with optional `references/`, `scripts/`, and `assets/`
subfolders — that originated at Anthropic and has since been adopted by Claude Code, Cursor, Codex
CLI, GitHub Copilot, OpenCode, and dozens of other agents. The same three skills work unchanged
across all of them; only where each agent looks for its skills directory differs.

## Why skills, not just docs

The pages in this site are for you to read. Skills are for an agent to read — each one is a
compact `SKILL.md` (plus deeper `references/*.md` files for less-common detail) written
specifically to steer an AI assistant toward the correct API shape, the right rule/annotation to
reach for, and the lifecycle rules (disposal, registration, async validation) that are easy to get
subtly wrong from first principles. Where this site explains *why* something works the way it
does, a skill is optimized to make the agent *do* the right thing by default, on the first
attempt, without you having to paste in explanations.

## The three skills

| Installed skill | Legacy `npx` name | Covers | Companion section |
|-----------------|-------------------|--------|-------------------|
| `validasi-guide` | `validasi` | Building schemas, `Rules.*`, transforms vs. preprocessing, custom sync/async rules, error handling | Core `validasi` |
| `validasi-gen-guide` | `validasi-gen` | `@ValidateClass`/`@Validate<T>` annotations, build flags and their gating rules, `@RefineFn`/cross-field sugar, extensibility (`Inline`, `CustomRule`, etc.) | [Code Generation](/companion/generator/overview) |
| `validasi-ui-guide` | `validasi-ui` | `ValidasiFormController` ownership/disposal, register/unregister and `shouldUnregister`, `ValidasiSubmit`'s sync/async paths, common lifecycle footguns | [Form Management](/companion/form-management/overview) |

Each skill's description is written to trigger even when you don't name the package explicitly —
e.g. asking an agent to "validate this form field" or "why does my controller throw after dispose"
is enough for the right skill to load.

## Install with `dart run skills@`

Make sure the package(s) you use are dependencies, then run the
[`skills` CLI](https://pub.dev/packages/skills) from your project root:

```bash
# Install selected skills from all dependencies
dart run skills@ get

# Install everything without prompting
dart run skills@ get --all

# Install only the skill shipped by one package
dart run skills@ get validasi_ui
```

The CLI scans each dependency for a `skills/` directory, copies the matching skill into the
right location for your agent, and tracks what it installed. Supported agents include Claude Code,
Cursor, Codex, GitHub Copilot, OpenCode, Cline, and Antigravity; the full list and per-agent
locations are in the [skills package documentation](https://pub.dev/packages/skills).

```bash
# See what is installed
dart run skills@ list

# Remove skills for packages no longer in your dependency tree
dart run skills@ prune
```

Skills are versioned with the package that ships them: `dart pub upgrade` plus
`dart run skills@ get` keeps them aligned with the APIs you actually resolve.

## Legacy install with `npx skills`

The top-level `skills/` mirror keeps the original skill names for the
[`npx skills`](https://github.com/vercel-labs/skills) workflow. It remains available for projects
that already use Node tooling, but the Dart installer is preferred.

```bash
# Install one skill
npx skills add albetnov/validasi --skill validasi-ui

# Install all three
npx skills add albetnov/validasi --all

# See what's installed, or search across skill repos
npx skills list
npx skills find validasi
```

## Manual install (no CLI)

Copy the relevant skill folder from the package that owns it — for example
`packages/validasi_ui/skills/validasi-ui-guide/` — into your agent's skills directory, keeping the
folder name and internal structure (`SKILL.md` plus its `references/` subfolder) intact. The
destination depends on your agent (`.claude/skills/` for Claude Code, `.agents/skills/` for
several others); check your agent's docs for its exact convention. Since `SKILL.md` is the same
format everywhere, nothing in the file itself needs rewriting.

You only need the skill(s) matching the packages you actually use — `validasi-ui-guide` isn't
useful in a backend-only project with no Flutter forms, for instance.

## Using them in this repo

If you're already working inside this monorepo, you can run `dart run skills@ get --all` from the
workspace root, or let any agent that discovers top-level `skills/` pick up the legacy mirror.
Either way the matching skill triggers based on its description whenever a task calls for it
(writing a schema, wiring a form, debugging a codegen build).

When editing a package skill, edit it under `packages/<package>/skills/` — that is the source of
truth. Regenerate the legacy mirror with `dart run melos run skills:sync`; CI verifies it with
`dart run melos run skills:check`.

## MCP server (deprecated)

The standalone `validasi_mcp` documentation server is deprecated in favor of these Agent Skills.
Skills ship the same guidance directly to your agent, so there is no runtime lookup step to
install or configure. The package is no longer documented or promoted on this site.
