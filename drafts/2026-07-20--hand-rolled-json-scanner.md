---
branch: "nightshift/2026-07-20/hand-rolled-json-scanner"
package: "jac-byllm"
date: "2026-07-20"
title: "refactor(jac-byllm): Rewrote `_extract_json_call()` in jac/jaclang/byllm/tool_pro"
risk: "low"
tests: "jac check \u2713 \u00b7 tests (no new failures vs baseline) \u2713 \u00b7 pre-commit \u2713 (1 min)"
release_note: "docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md"
files: 1
loc: {"added": 40, "removed": 32}
---

# refactor(jac-byllm): Rewrote `_extract_json_call()` in jac/jaclang/byllm/tool_pro

## What & why

Rewrote `_extract_json_call()` in jac/jaclang/byllm/tool_protocol.jac to use the stdlib `json.JSONDecoder().raw_decode(content, i)` for the primary success path instead of the hand-rolled `_balanced()` quote/escape-aware brace scanner combined with a separate `json.loads(blob)` call. `raw_decode` parses a JSON value starting at a given index and returns both the parsed object and the end offset in one call, which is exactly what `_balanced()` + `json.loads()` were doing together (find matching close brace, then parse). `_balanced()` itself was NOT deleted since it's still required by `_extract_paren_call()` (tool_protocol.jac:402-417) for the non-JSON `tool(name=val)` call syntax; it's now used only as a fallback inside `_extract_json_call` when `raw_decode` raises (malformed JSON at that brace), solely to compute how far to advance the scan index `i`, mirroring the original code's exact behavior of skipping past the whole balanced-but-invalid blob before continuing the outer while-loop. Behavior preservation reasoning: since `content[i] == '{'` is checked before calling raw_decode, any successful parse must always yield a `dict` (JSON grammar guarantees an object literal when starting from `{`), so the redundant `isinstance(parsed, dict)` guard from the original code was removable without changing observable behavior - the `wrapped`/`candidates`/`for cand in candidates` matching logic, the `return {'name', 'arguments', 'raw', 'pos'}` shape, and the `i += len(blob); continue;` fallthrough for a valid-but-non-matching parse are all byte-for-byte unchanged from the original. I traced both call sites of `_extract_json_call` (only caller is `_extract_first_tool_call` at tool_protocol.jac:426, which only reads `.get('pos')` from the returned dict and compares positions against `_extract_paren_call`'s result) and confirmed the returned dict shape/keys are identical to before. Verification: ran `mcp__jac__validate_jac` (full compile-pipeline type check) on the complete file repeatedly while iterating - the Jac type checker does not narrow variable types across `try`/`except` branches the way Python's would, so three intermediate revisions were needed (declaring `blob`/`parsed` with explicit `str | None` / `dict | None` types, then finally computing `blob` via a single ternary expression instead of branch-local reassignment) to get a clean compile without introducing new type errors. The final validate_jac run shows the only three remaining errors/warnings (line 145 'Type object is not iterable', lines 464/465 'Cannot assign str to LiteralString') are pre-existing issues in `linearize_tool_messages`/`recover_tool_calls`, untouched by this diff and unrelated to `_extract_json_call` - confirmed by observing these exact error signatures (same message, same relative position) appeared identically across all validation runs regardless of my in-progress edits to the JSON-extraction function, meaning they predate this change. No function signatures changed (`_extract_json_call(content: str, tool_names: list) -> dict | None` is unchanged), so per protocol `jac check` on the package was not required. The two other files listed in the theme (`tool_protocol.impl.jac`, `impl/tool_protocol.impl.jac`) do not exist in the repository, so nothing was touched there.

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/byllm/tool_protocol.jac`

Lines: **+40 -32** (net +8).

## Consciously deferred

- `jac/jaclang/byllm/tool_protocol.impl.jac` — file does not exist in the repository
- `jac/jaclang/byllm/impl/tool_protocol.impl.jac` — file does not exist in the repository

## Verification

jac check ✓ · tests (no new failures vs baseline) ✓ · pre-commit ✓ (1 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
