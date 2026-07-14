---
branch: "nightshift/2026-07-13/react-loop-duplication"
package: "jac-byllm"
date: "2026-07-13"
title: "refactor(jac-byllm): _invoke_streaming's tool branch duplicated ~150 lines of _in"
risk: "low"
tests: "jac check + tests + pre-commit OK"
release_note: "docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md"
files: 1
loc: {"added": 90, "removed": 77}
---

# refactor(jac-byllm): _invoke_streaming's tool branch duplicated ~150 lines of _in

## What & why

_invoke_streaming's tool branch duplicated ~150 lines of _invoke_react_loop's max_iters/on_iteration/compaction/dispatch logic nearly verbatim. A full merge was too risky (score's risk=4 was right): one loop returns a value, the other yields a StreamEvent per step, so unifying them needs a generator/callback redesign of the loop itself, not a mechanical edit. Instead, extracted the four pieces that were byte-for-byte identical between the loops into shared helpers - _react_loop_config (max_iters/on_iteration/compaction resolution), _split_finish_call (tool-call splitting at finish_tool), _batch_tool_calls (parallel/sequential batching), and _resolve_iteration_action (on_iteration hook invocation) - and reused the existing _usage_int helper for the total_tokens accumulation both loops already duplicated inline. Verified via `jac check` on the full byllm package before and after: error count went from 185 to 183 (net improvement - the refactor also resolved a pre-existing ToolCall|None type ambiguity) and warnings rose by only 2, both benign unparameterized-generic style nits already common in this file.

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/byllm/llm.impl/basellm.impl.jac`

Lines: **+90 -77** (net +13).

## Consciously deferred

- `jac/jaclang/byllm/llm.impl/basellm.impl.jac` — Full merge of _invoke_react_loop and _invoke_streaming's tool branch (the ~150-line duplication the finding flagged) was skipped as too risky: one path returns a value, the other yields StreamEvent objects per step (thought/tool_call/tool_result/tool_timing/llm_timing), so unifying control flow requires a generator/callback redesign, not a safe mechanical dedup. Did a conservative partial extraction instead (see summary) that removes true byte-identical duplication with verified zero behavior change; left a `# ponytail:` comment at the remaining duplication site naming the redesign needed to go further.

## Verification

jac check + tests + pre-commit OK

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
