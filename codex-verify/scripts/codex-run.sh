#!/bin/bash
# codex-run.sh — Wrapper for Codex CLI verification calls
# Encapsulates flag management, prompt selection, timeout handling, and output capture.
#
# Usage:
#   codex-run.sh <phase> <scope> <output_file> [files_or_args...]
#
# Arguments:
#   phase:   defects | quality
#   scope:   diff | branch | file
#   output:  path to write Codex output (use mktemp for unique paths)
#   files:   space-separated file paths (required for file scope, rejected for diff/branch)
#   --lang <language>: output language for Codex responses (e.g., zh-CN, ja, ko, en). Defaults to English if omitted.
#   --custom "prompt": optional modifier that adds custom criteria to any scope
#   --base <branch>: base branch name (required for branch scope)
#   --dry-run: print the command and prompt without executing
#
# The scope names (diff/branch/file) match the terminology in SKILL.md.
# Internally the script maps them to the correct Codex CLI invocation:
#   diff   → codex exec review --uncommitted [PROMPT]
#   branch → codex exec review --base <branch> [PROMPT]
#   file   → codex exec (with file list in prompt)
#
# --custom is a modifier, not a scope. It prepends custom criteria to the
# phase-specific prompt and works with any scope (diff, branch, or file).
#
# Examples:
#   codex-run.sh defects file /tmp/out.md src/auth.ts src/utils.ts
#   codex-run.sh defects branch /tmp/out.md --base main
#   codex-run.sh defects diff /tmp/out.md
#   codex-run.sh quality file /tmp/out.md src/auth.ts
#   codex-run.sh defects file /tmp/out.md src/auth.ts --lang zh-CN
#   codex-run.sh defects diff /tmp/out.md --lang ja
#   codex-run.sh defects file /tmp/out.md src/auth.ts --custom "check for memory leaks"
#   codex-run.sh defects diff /tmp/out.md --custom "focus on XSS vulnerabilities"
#   codex-run.sh defects file /tmp/out.md src/auth.ts --dry-run

# Do NOT use set -e — we need to capture exit codes for error diagnostics
set -uo pipefail

# ─── Globals (populated by parse_args + validate_args) ───
PHASE=""
SCOPE=""
OUTPUT=""
LANG=""
CUSTOM_PROMPT=""
BASE_BRANCH=""
FILES=()
DRY_RUN=false
TIMEOUT_CMD=""
TIMEOUT_VAL=300
PROMPT=""
CMD=()

# ─── Functions ───

parse_args() {
  PHASE="${1:?Usage: codex-run.sh <phase> <scope> <output> [files...]}"
  SCOPE="${2:?}"
  OUTPUT="${3:?}"
  shift 3

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --custom)
        [[ $# -ge 2 ]] || { echo "Error: --custom requires a prompt value"; exit 1; }
        CUSTOM_PROMPT="$2"
        shift 2
        ;;
      --base)
        [[ $# -ge 2 ]] || { echo "Error: --base requires a branch name"; exit 1; }
        BASE_BRANCH="$2"
        shift 2
        ;;
      --lang)
        [[ $# -ge 2 ]] || { echo "Error: --lang requires a language value (e.g., zh-CN, ja, ko, en)"; exit 1; }
        LANG="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      *)
        FILES+=("$1")
        shift
        ;;
    esac
  done
}

validate_args() {
  # Phase must be known before any prompt/command building
  case "$PHASE" in
    defects|quality) ;;
    *) echo "Error: Unknown phase '$PHASE'. Use: defects, quality."; exit 1 ;;
  esac

  # Scope + required/forbidden args
  case "$SCOPE" in
    diff)
      [[ ${#FILES[@]} -eq 0 ]] || { echo "Error: diff scope does not accept file paths. Use file scope instead."; exit 1; }
      ;;
    branch)
      [[ -n "$BASE_BRANCH" ]] || { echo "Error: branch scope requires --base <branch>"; exit 1; }
      [[ ${#FILES[@]} -eq 0 ]] || { echo "Error: branch scope does not accept file paths. Use file scope instead."; exit 1; }
      ;;
    file)
      [[ ${#FILES[@]} -gt 0 ]] || { echo "Error: file scope requires at least one file path"; exit 1; }
      ;;
    *)
      echo "Error: Unknown scope '$SCOPE'. Use: diff, branch, file."
      echo "Tip: --custom is a modifier, not a scope. Combine it with diff, branch, or file."
      exit 1
      ;;
  esac
}

detect_timeout() {
  if command -v timeout &>/dev/null; then
    TIMEOUT_CMD="timeout"
  elif command -v gtimeout &>/dev/null; then
    TIMEOUT_CMD="gtimeout"
  fi
}

build_prompt() {
  # Base prompt from phase
  case "$PHASE" in
    defects)
      PROMPT='You are a code reviewer focused on finding defects. Carefully review the specified code for:
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

If no defects are found, state: "No defects found in the reviewed code."'
      ;;
    quality)
      PROMPT='You are a code quality reviewer. Evaluate the specified code on these five dimensions:
1. Architecture & Design — Is the structure sound? Are responsibilities well-separated? Is there appropriate abstraction without over-engineering?
2. Readability & Naming — Are names clear and self-documenting? Is the intent obvious without comments? Is the code easy to follow?
3. Maintainability — Can this code be extended or modified without pain? Are there hidden dependencies or tight coupling?
4. Performance — Are there unnecessary inefficiencies? Could algorithms or data structures be improved? Are there N+1 queries or redundant computations?
5. Testability — Is the code structured so unit tests are easy to write? Are side effects isolated? Can components be tested independently?

Rate each dimension 1-5 (1=poor, 5=excellent) and provide specific, actionable improvement suggestions for any dimension rated below 4. Be concise — one suggestion per low-rated dimension is enough.'
      ;;
  esac

  # Custom modifier: prepend user criteria
  if [[ -n "$CUSTOM_PROMPT" ]]; then
    PROMPT="Additional verification criteria from the user: $CUSTOM_PROMPT

$PROMPT"
  fi

  # File targets: append for file scope
  if [[ "$SCOPE" == "file" ]] && [[ ${#FILES[@]} -gt 0 ]]; then
    FILE_LIST=$(printf '%s\n' "${FILES[@]}")
    PROMPT="$PROMPT

Files to review:
$FILE_LIST"
  fi

  # Language instruction: tell Codex to respond in the specified language
  if [[ -n "$LANG" ]]; then
    PROMPT="$PROMPT

IMPORTANT: Write your entire response in $LANG. All descriptions, explanations, and suggestions must be in $LANG. Keep technical identifiers (file paths, function names, variable names) in their original form, but all prose content must be in $LANG."
  fi
}

determine_timeout() {
  TIMEOUT_VAL=300
  if [[ "$SCOPE" == "diff" ]] || [[ "$SCOPE" == "branch" ]]; then
    TIMEOUT_VAL=600
  elif [[ ${#FILES[@]} -gt 5 ]]; then
    TIMEOUT_VAL=600
  fi
}

build_command() {
  CMD=()

  # Prepend timeout if available
  if [[ -n "$TIMEOUT_CMD" ]]; then
    CMD+=("$TIMEOUT_CMD" "$TIMEOUT_VAL")
  fi

  # Codex invocation based on scope
  case "$SCOPE" in
    diff)
      CMD+=(codex exec review --skip-git-repo-check --ephemeral -s read-only -o "$OUTPUT" --uncommitted "$PROMPT")
      ;;
    branch)
      CMD+=(codex exec review --skip-git-repo-check --ephemeral -s read-only -o "$OUTPUT" --base "$BASE_BRANCH" "$PROMPT")
      ;;
    file)
      CMD+=(codex exec --skip-git-repo-check --ephemeral -s read-only -o "$OUTPUT" "$PROMPT")
      ;;
  esac
}

# Build a fallback command (same scope/prompt but with --json instead of -o)
build_fallback_command() {
  local jsonl_out="$1"
  CMD=()

  if [[ -n "$TIMEOUT_CMD" ]]; then
    CMD+=("$TIMEOUT_CMD" "$TIMEOUT_VAL")
  fi

  case "$SCOPE" in
    diff)
      CMD+=(codex exec review --skip-git-repo-check --json --ephemeral -s read-only --uncommitted "$PROMPT")
      ;;
    branch)
      CMD+=(codex exec review --skip-git-repo-check --json --ephemeral -s read-only --base "$BASE_BRANCH" "$PROMPT")
      ;;
    file)
      CMD+=(codex exec --skip-git-repo-check --json --ephemeral -s read-only "$PROMPT")
      ;;
  esac
}

# Parse JSONL output and write final assistant message to OUTPUT
parse_jsonl_to_output() {
  local jsonl_file="$1"

  if command -v jq &>/dev/null; then
    # Use jq for reliable parsing
    local msg
    msg=$(grep '"type":"message"' "$jsonl_file" | grep '"role":"assistant"' | tail -1 | jq -r '.content[0].text')
    if [[ -n "$msg" ]]; then
      echo "$msg" > "$OUTPUT"
      return 0
    fi
  fi

  # Fallback without jq: extract text between quotes
  local msg
  msg=$(grep '"role":"assistant"' "$jsonl_file" | tail -1 | sed 's/.*"text":"//; s/".*//')
  if [[ -n "$msg" ]]; then
    echo "$msg" > "$OUTPUT"
    return 0
  fi

  return 1
}

# ─── Main ───

parse_args "$@"
validate_args
detect_timeout
build_prompt
determine_timeout
build_command

# Dry-run: print command and prompt without executing
if [[ "$DRY_RUN" == true ]]; then
  echo "=== DRY RUN ==="
  echo "Command array:"
  printf '  %s\n' "${CMD[@]}"
  echo ""
  echo "=== PROMPT ==="
  echo "$PROMPT"
  echo ""
  echo "=== OUTPUT TARGET ==="
  echo "$OUTPUT"
  exit 0
fi

# Execute with exit code capture
echo "Running Codex (phase=$PHASE, scope=$SCOPE, timeout=${TIMEOUT_VAL}s)..."
CODEX_EXIT=0
"${CMD[@]}" || CODEX_EXIT=$?

if [[ $CODEX_EXIT -ne 0 ]]; then
  echo "ERROR: Codex exited with code $CODEX_EXIT"
  exit "$CODEX_EXIT"
fi

# Check output file — try JSONL fallback automatically if empty
if [[ ! -f "$OUTPUT" ]] || [[ ! -s "$OUTPUT" ]]; then
  echo "WARNING: Output file is empty or missing. Trying JSONL fallback..."

  JSONL_OUT=$(mktemp)
  build_fallback_command "$JSONL_OUT"

  FALLBACK_EXIT=0
  "${CMD[@]}" > "$JSONL_OUT" 2>&1 || FALLBACK_EXIT=$?

  if [[ $FALLBACK_EXIT -ne 0 ]]; then
    echo "ERROR: Codex fallback also failed (exit code $FALLBACK_EXIT)"
    rm -f "$JSONL_OUT"
    exit "$FALLBACK_EXIT"
  fi

  if parse_jsonl_to_output "$JSONL_OUT"; then
    rm -f "$JSONL_OUT"
    echo "Fallback succeeded. Output written to: $OUTPUT"
    WORD_COUNT=$(wc -w < "$OUTPUT" | tr -d ' ')
    echo "Output length: ~${WORD_COUNT} words"
    exit 0
  else
    echo "ERROR: Could not extract assistant message from JSONL fallback."
    rm -f "$JSONL_OUT"
    exit 1
  fi
fi

echo "Output written to: $OUTPUT"
WORD_COUNT=$(wc -w < "$OUTPUT" | tr -d ' ')
echo "Output length: ~${WORD_COUNT} words"