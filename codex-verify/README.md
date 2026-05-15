# codex-verify

Use OpenAI Codex CLI (GPT-5.5 or other configured model) to independently verify and review code that Claude has written. Designed for the "design with Claude, verify with Codex" workflow — getting a second opinion from a different model to catch issues Claude might miss.

## Features

- **Two-phase verification**: Defect detection (bugs, security, logic errors) + Quality assessment (architecture, readability, maintainability, performance, testability)
- **Multiple verification scopes**: diff (uncommitted changes), branch (compare against base), file (target specific files)
- **Custom modifier**: `--custom` adds user-specified verification criteria on top of any scope
- **Language support**: `--lang` tells Codex to respond in the user's language (e.g., `--lang zh-CN`, `--lang ja`)
- **Safe command construction**: Bash arrays instead of eval — no injection risk
- **Automatic JSONL fallback**: If output capture fails, automatically retries with JSONL parsing
- **Dry-run mode**: Preview the exact command and prompt without executing
- **Argument validation**: Rejects invalid combinations (e.g., file paths with diff scope)

## Installation

```bash
npx skills add liwuhou/skills/codex-verify
```

Prerequisite: Codex CLI must be installed and configured (`npm install -g @openai/codex`).

## Usage

### Verify specific files (both phases)
```bash
/codex-verify file both src/auth.ts src/utils.ts
```

### Verify uncommitted changes (defects only)
```bash
/codex-verify diff defects
```

### Verify branch comparison
```bash
/codex-verify branch both --base main
```

### Custom verification criteria
```bash
/codex-verify file both src/auth.ts --custom "focus on memory leaks and XSS"
```

### Output in a specific language
```bash
/codex-verify file both src/auth.ts --lang zh-CN
/codex-verify diff defects --lang ja
```

### Quick check (defects only, skip quality assessment)
```bash
/codex-verify diff defects
```

## Verification Output

The skill presents results in a structured format:

### Phase 1: Defect Detection
| Severity | Location | Description |
|----------|----------|-------------|
| critical | file:line | ... |
| high     | file:line | ... |

### Phase 2: Quality Assessment
| Dimension | Rating (1-5) | Notes |
|-----------|--------------|-------|
| Architecture | 4 | ... |
| Readability | 3 | ... |

All fixes require **explicit user approval** — the skill never auto-fixes, even for critical defects.

## Design Philosophy

This skill was built through 4 rounds of iterative verification using itself (Claude writes → Codex verifies → fix issues → re-verify). Key safety decisions:

- No `eval` — commands built as Bash arrays to prevent injection
- No auto-fix — Codex results are advisory, user must approve changes
- Scope always has a concrete code target — `--custom` is a modifier, not a standalone scope
- `mktemp` for output paths — prevents concurrent run collisions
- Automatic JSONL fallback when output capture fails

## License

MIT