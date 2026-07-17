# Agent Skills

This repository ships three [Agent Skills](https://agentskills.io) — curated, always-loadable
references that shape how an AI coding agent writes `validasi` code, rather than a tool it has to
go looking for. They live in this repo's `skills/` directory, one per package, mirroring the same
split as the rest of these docs.

**They aren't Claude Code–specific.** `SKILL.md` is an open format — YAML frontmatter (`name`,
`description`) plus a Markdown body, with optional `references/`, `scripts/`, and `assets/`
subfolders — that originated at Anthropic and has since been adopted by Claude Code, Cursor, Codex
CLI, GitHub Copilot, OpenCode, and dozens of other agents. The same three files here work unchanged
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

| Skill | Covers | Companion section |
|-------|--------|-------------------|
| `validasi` | Building schemas, `Rules.*`, transforms vs. preprocessing, custom sync/async rules, error handling | Core `validasi` |
| `validasi-gen` | `@ValidateClass`/`@Validate<T>` annotations, build flags and their gating rules, `@RefineFn`/cross-field sugar, extensibility (`Inline`, `CustomRule`, etc.) | [Code Generation](/companion/generator/overview) |
| `validasi-ui` | `ValidasiFormController` ownership/disposal, register/unregister and `shouldUnregister`, `ValidasiSubmit`'s sync/async paths, common lifecycle footguns | [Form Management](/companion/form-management/overview) |

Each skill's description is written to trigger even when you don't name the package explicitly —
e.g. asking an agent to "validate this form field" or "why does my controller throw after dispose"
is enough for the right skill to load.

## Install with `npx skills`

The fastest way to pull these into your own project is the open-source
[`skills` CLI](https://github.com/vercel-labs/skills) (`npx skills`) — it works against any public
GitHub repo containing `skills/<name>/SKILL.md` files, which is exactly this repo's layout, no
extra manifest required. It also auto-detects which agent you're using and installs into that
agent's convention (`.claude/skills/`, `.agents/skills/` for Cursor/Codex/Cline/Warp/Zed,
`.continue/skills/`, and so on) for you.

```bash
# Install one skill
npx skills add albetnov/validasi --skill validasi-ui

# Install all three
npx skills add albetnov/validasi --all

# See what's installed, or search across skill repos
npx skills list
npx skills find validasi
```

## Manual install (no Node/npx)

If `npx` isn't an option, copy the relevant skill folder — e.g. `skills/validasi-ui/` — from this
repository into your agent's skills directory, keeping the folder name and internal structure
(`SKILL.md` plus its `references/` subfolder) intact. The destination directory depends on your
agent (`.claude/skills/` for Claude Code, `.agents/skills/` for several others) — check your
agent's docs for its exact convention. Since `SKILL.md` is the same format everywhere, nothing in
the file itself needs rewriting.

You only need the skill(s) matching the packages you actually use — `validasi-ui`'s skill isn't
useful in a backend-only project with no Flutter forms, for instance.

## Using them in this repo

If you're already working inside this monorepo, nothing to install — any agent that supports the
Agent Skills format discovers `skills/` on its own and triggers the matching skill based on its
description whenever a task calls for it (writing a schema, wiring a form, debugging a codegen
build). This isn't specific to any one agent — it's how project-level skill discovery works across
the whole ecosystem.

## Skills vs. the MCP server

These solve different problems, and you can use either or both:

- **[MCP server](/companion/mcp-server)** (`validasi_mcp`) is a *lookup tool* — your agent calls it
  at runtime to search or fetch this docs site when it needs to look something up. Useful for
  anything not baked into a skill, or for keeping up with docs changes without updating a skill.
- **Skills** are *authored guidance* — they're already loaded before the agent writes a line of
  code, encoding the lifecycle rules, gotchas, and "reach for X, not Y" decisions that are tedious
  to re-derive from a documentation lookup every time.

Using both means your agent starts from the skill's curated judgment and can still fall back to
the MCP server for anything the skill doesn't cover. Both work the same way regardless of which
MCP-and-skills-compatible agent you're using.
