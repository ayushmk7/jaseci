---
branch: "nightshift/2026-07-24/speculative-paren-call-parser"
package: "jac-byllm"
date: "2026-07-24"
title: "refactor(jac-byllm): Deleted the speculative parenthesis-call recovery path in ja"
risk: "low"
tests: "jac check \u2713 \u00b7 tests (no new failures vs baseline) \u2713 \u00b7 pre-commit \u2713 (1 min)"
release_note: "docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md"
files: 1
loc: {"added": 2, "removed": 109}
---

# refactor(jac-byllm): Deleted the speculative parenthesis-call recovery path in ja

## What & why

Deleted the speculative parenthesis-call recovery path in jac/jaclang/byllm/tool_protocol.jac. `format_tools_for_prompt` (the only place that instructs a model how to emit a tool call) documents exactly one syntax: `<tool_call>{"name": ..., "arguments": {...}}</tool_call>`. Despite that, `recover_tool_calls` also tried to parse a second, never-instructed `tool_name(arg=val, ...)` syntax via `_extract_paren_call`, backed by `_split_top_level` (comma-splitting with bracket/quote awareness), `_parse_value` (JSON/quoted-literal coercion), and `_parse_kwargs` (kwarg parsing) - about 90 lines - plus the merge logic in `_extract_first_tool_call` that picked whichever of the JSON or paren match occurred earlier in the text. I grepped the entire repo for `_extract_paren_call`, `_extract_first_tool_call`, `_split_top_level`, `_parse_kwargs`, and `_parse_value`: all only appear inside this one file, confirming nothing else calls or depends on them. I read `jac/jaclang/byllm/tests/test_byllm.jac`'s `recover_tool_calls` regression test (around line 1611, 'recover_tool_calls handles an object-shaped reply') and confirmed it only exercises the documented JSON `<tool_call>{...}</tool_call>` shape - no fixture anywhere produces or expects the parenthesis-call syntax. Removed the four dead helper functions and simplified `recover_tool_calls`'s call site from `_extract_first_tool_call(content, names)` to `_extract_json_call(content, names)` directly (the only surviving extractor), since there's no longer a second candidate to arbitrate between. `_balanced` is kept - it's still used by `_extract_json_call` for brace-matching JSON blobs. No public function signature changed (`recover_tool_calls`, `format_tools_for_prompt`, `inject_tool_hint`, etc. are all untouched), so no `jac check` was needed per protocol. Verification: ran `mcp__jac__validate_jac` on the full new file content - it reported the same 3 pre-existing errors (lines 145, 350, 351) and warnings that exist on the unmodified file (confirmed via `git show HEAD:.../tool_protocol.jac` at those same line numbers - they're standalone-snippet type-resolution artifacts unrelated to this edit, e.g. `object`-typed iteration and literal-narrowing on code I never touched). Then ran `jac test jaclang/byllm/tests/test_byllm.jac` for the full suite: 98 passed, 1 skipped (same as before), including the specific `recover_tool_calls handles an object-shaped reply` test run in isolation first.

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/byllm/tool_protocol.jac`

Lines: **+2 -109** (net -107).

## Verification

jac check ✓ · tests (no new failures vs baseline) ✓ · pre-commit ✓ (1 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
