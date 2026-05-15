# Verification Prompt Templates

**Note**: This file is a reference document that mirrors the prompt text in `scripts/codex-run.sh` (canonical source). Read this file for customization guidance, but **never copy prompt text from it into manual commands** — use the script instead, which handles flag management and prompt assembly.

If you customize prompts, update the script's heredocs. This reference file should then be updated to stay in sync, or you can add `--custom` to override prompts per-invocation without modifying the script.

## Phase 1: Defect Detection Prompt

```
You are a code reviewer focused on finding defects. Carefully review the specified code for:

- Bugs and logic errors
- Security vulnerabilities (OWASP top 10)
- Race conditions and concurrency issues
- Null/undefined access and type mismatches
- Incorrect error handling and missing edge cases
- Resource leaks (memory, file handles, connections)

For each defect found, provide:
1. Location: file:line (or approximate if exact line unknown)
2. Severity: critical / high / medium / low
3. Description: what the defect is and why it matters
4. Suggested fix: concrete code change to resolve it

If no defects are found, state: "No defects found in the reviewed code."
```

## Phase 2: Quality Assessment Prompt

```
You are a code quality reviewer. Evaluate the specified code on these five dimensions:

1. Architecture & Design — Is the structure sound? Are responsibilities well-separated? Is there appropriate abstraction without over-engineering?
2. Readability & Naming — Are names clear and self-documenting? Is the intent obvious without comments? Is the code easy to follow?
3. Maintainability — Can this code be extended or modified without pain? Are there hidden dependencies or tight coupling?
4. Performance — Are there unnecessary inefficiencies? Could algorithms or data structures be improved? Are there N+1 queries or redundant computations?
5. Testability — Is the code structured so unit tests are easy to write? Are side effects isolated? Can components be tested independently?

Rate each dimension 1-5 (1=poor, 5=excellent) and provide specific, actionable improvement suggestions for any dimension rated below 4. Be concise — one suggestion per low-rated dimension is enough.
```

## Language Modifier (--lang)

The `--lang` flag tells Codex to write its entire response in the specified language. The script appends this instruction at the end of the prompt:

```
IMPORTANT: Write your entire response in <LANG>. All descriptions, explanations, and suggestions must be in <LANG>. Keep technical identifiers (file paths, function names, variable names) in their original form, but all prose content must be in <LANG>.
```

This flag works with any scope and any phase. If omitted, Codex defaults to English.

Common language codes:
- `zh-CN` — 简体中文 (Simplified Chinese)
- `zh-TW` — 繁体中文 (Traditional Chinese)
- `ja` — 日本語 (Japanese)
- `ko` — 한국어 (Korean)
- `fr` — Français (French)
- `de` — Deutsch (German)
- `es` — Español (Spanish)
- `pt` — Português (Portuguese)
- `ru` — Русский (Russian)
- `en` — English

## Custom Modifier (--custom)

The `--custom` flag is a modifier, not a standalone scope. It works with any scope (diff, branch, or file) to add user-specified criteria. The script prepends this framing before the base prompt:

```
Additional verification criteria from the user: <USER_CUSTOM_TEXT>
```

Then the full base prompt follows. This ensures the review always has both a concrete code target (from the scope) and any additional focus areas the user wants.

## Prompt Tips

- For security-focused reviews, add via `--custom`: "Focus specifically on OWASP top 10: injection, XSS, auth bypass, insecure storage, SSRF, misconfiguration."
- For performance-focused reviews, add: "Focus on: algorithmic complexity, memory usage, I/O patterns, caching opportunities, database query efficiency."
- For frontend code, add: "Check for: accessibility violations, responsive design issues, state management correctness, render performance concerns."