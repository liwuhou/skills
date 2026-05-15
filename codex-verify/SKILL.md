---
name: codex-verify
description: Use OpenAI Codex CLI (GPT-5.5) to verify and review code written by Claude. Invoke this skill whenever you want a second opinion on code quality, need to cross-check for bugs or security issues, or want an independent model to validate your work. Use it after writing or modifying code, before committing changes, or when the user asks to verify, validate, review, double-check, or cross-validate code. Also triggers on phrases like "let codex check this", "run codex verification", "verify with gpt", "codex review", or "second opinion on this code".
argument-hint: "[scope: diff|branch|file] [phase: defects|quality|both] [--base <branch>] [--files <paths>] [--lang <language>] [--custom <prompt>]"
---

## What this skill does

Calls Codex CLI (GPT-5.5) to independently verify code that Claude has written, running a two-phase verification by default:

1. **Phase 1 — Defect Detection**: bugs, security vulnerabilities, logic errors, edge cases
2. **Phase 2 — Quality Assessment**: architecture, readability, maintainability, performance, testability

Results come back into Claude's context so you can act on them — but only after user approval.

## Terminology

This skill uses consistent terminology across all files:

- **scope** (diff/branch/file): what code to verify — always specifies a concrete review target
- **phase** (defects/quality/both): which verification phase to run
- **--custom**: a modifier that adds user-specified criteria to any scope, not a standalone scope

The script `codex-run.sh` accepts the same scope names and internally maps them to the correct Codex CLI invocation. No separate "exec vs review" mode distinction is exposed to users.

## Workflow Checklist

- [ ] **Determine verification scope** ⚠️ BLOCKING — ask the user if scope is unclear
  - [ ] Parse user arguments for `scope`, `phase`, `base`, `files`, `custom`, `lang`
  - [ ] Ask yourself: Has the user named specific files? → **file** scope
  - [ ] Ask yourself: Did the user mention a branch comparison? → **branch** scope
  - [ ] Ask yourself: Are there uncommitted git changes and no explicit scope? → **diff** scope (default)
  - [ ] Ask yourself: Did the user give a custom instruction like "check for memory leaks"? → **file** scope (or whatever scope applies) + `--custom` modifier — never use custom as a standalone scope
  - [ ] If still unclear, ask the user before proceeding ⚠️
- [ ] **Determine output language** — detect the language the user is writing in and pass it via `--lang`
  - [ ] If the user explicitly specifies a language → use that value
  - [ ] If not specified → detect from the user's current conversation language (e.g., writing in Chinese → `--lang zh-CN`, Japanese → `--lang ja`, Korean → `--lang ko`)
  - [ ] If the conversation is in English → omit `--lang` (Codex defaults to English)
  - [ ] Common language codes: `zh-CN` (简体中文), `zh-TW` (繁体中文), `ja` (日本語), `ko` (한국어), `fr` (Français), `de` (Deutsch), `es` (Español), `pt` (Português), `ru` (Русский), `en` (English)
- [ ] **Generate unique output paths** — use `mktemp` to avoid collisions between concurrent runs
  ```bash
  DEFECTS_OUT=$(mktemp) && QUALITY_OUT=$(mktemp)
  ```
- [ ] **Phase 1: Defect Detection** (conditional: skip if phase=quality)
  - [ ] Run: `scripts/codex-run.sh defects <scope> "$DEFECTS_OUT" [scope-specific args]`
  - [ ] Read output from `$DEFECTS_OUT`
  - [ ] If output is empty or errors occurred → try fallback (see Error handling)
- [ ] **Phase 2: Quality Assessment** (conditional: skip if phase=defects)
  - [ ] Run: `scripts/codex-run.sh quality <scope> "$QUALITY_OUT" [scope-specific args]`
  - [ ] Read output from `$QUALITY_OUT`
  - [ ] If output is empty → same fallback strategy
- [ ] **Present findings to user** ⚠️ BLOCKING — always show results before acting
- [ ] **Ask user what to fix** ⚠️ BLOCKING — never auto-fix, even critical defects. Codex can be wrong.
- [ ] Apply only user-approved fixes
- [ ] Re-verify if user requests it (conditional)

## Scope Commands

All verification runs go through `scripts/codex-run.sh`, which handles CLI flags, prompt selection, and timeout internally using Bash arrays (no eval, no injection risk).

| Scope | Script invocation | Required args |
|-------|-------------------|---------------|
| **diff** | `scripts/codex-run.sh defects diff "$DEFECTS_OUT"` | none (reviews uncommitted changes) |
| **branch** | `scripts/codex-run.sh defects branch "$DEFECTS_OUT" --base "$BRANCH"` | `--base` with quoted branch name |
| **file** | `scripts/codex-run.sh defects file "$DEFECTS_OUT" file1.ts file2.ts` | file paths as positional args |

The `--custom` modifier works with any scope to add user-specified verification criteria:
```bash
# Custom criteria on specific files
scripts/codex-run.sh defects file "$DEFECTS_OUT" src/auth.ts --custom "focus on memory leaks"

# Custom criteria on uncommitted changes
scripts/codex-run.sh defects diff "$DEFECTS_OUT" --custom "focus on XSS vulnerabilities"
```

The `--lang` flag tells Codex to write its response in the specified language:
```bash
# Output in Chinese
scripts/codex-run.sh defects file "$DEFECTS_OUT" src/auth.ts --lang zh-CN

# Output in Japanese
scripts/codex-run.sh quality diff "$QUALITY_OUT" --lang ja
```

For Phase 2, use the same scope and same args, just change `defects` to `quality`:
```bash
scripts/codex-run.sh quality file "$QUALITY_OUT" file1.ts file2.ts
```

To preview a command without executing:
```bash
scripts/codex-run.sh defects file "$DEFECTS_OUT" src/auth.ts --dry-run
```

See `references/codex-cmds.md` for detailed CLI options and the `--json` fallback strategy.

## Prompt templates

Prompt text is embedded in `scripts/codex-run.sh` (canonical source). `references/prompts.md` is a reference document that mirrors the script's prompts — read it for customization guidance, but never copy prompt text from it into manual commands. Use the script instead.

## Presenting results to the user

**Language rule**: Present results in the same language the user is using in the current conversation. If the user is writing in Chinese, present results in Chinese; if Japanese, present in Japanese; etc. Technical identifiers (file paths, function names, variable names) stay in their original form, but all prose — descriptions, suggestions, explanations, headers — must match the user's language.

Use this template when summarizing findings (adapt all prose to the user's language):

```
## Codex Verification Results

### Phase 1: Defect Detection
| Severity | Location | Description |
|----------|----------|-------------|
| critical | file:line | ... |
| high     | file:line | ... |
| medium   | file:line | ... |
| low      | file:line | ... |

Defects found: X (critical: Y, high: Z)

### Phase 2: Quality Assessment
| Dimension | Rating (1-5) | Notes |
|-----------|--------------|-------|
| Architecture | ... | ... |
| Readability | ... | ... |
| Maintainability | ... | ... |
| Performance | ... | ... |
| Testability | ... | ... |

Overall quality: X/5

### Recommended Actions
[List suggested fixes, marked by user approval status]
```

## Error handling

- `codex` not found → tell user to install: `npm install -g @openai/codex`
- Auth error → suggest `codex login` or check `~/.codex/config.toml`
- Not in git repo → script adds `--skip-git-repo-check` automatically
- Codex nonzero exit → script prints error code and fallback guidance, then exits with same code
- Empty output → script prints warning and fallback guidance
- Timeout → script auto-detects `timeout`/`gtimeout` and wraps the command; Bash tool timeout (300-600s) serves as outer safety net

## Skipping a phase

If the user specifies `phase=defects`, skip Phase 2. If `phase=quality`, skip Phase 1. Default is `both`. Respect explicit user preferences over the default.