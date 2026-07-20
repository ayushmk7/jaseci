---
branch: "nightshift/2026-07-20/manual-thread-timeout"
package: "jac-byllm"
date: "2026-07-20"
title: "refactor(jac-byllm): Simplified `_call_sync()` in jac/jaclang/byllm/parallel.jac "
risk: "low"
tests: "jac check \u2713 \u00b7 tests (no new failures vs baseline) \u2713 \u00b7 pre-commit \u2713 (1 min)"
release_note: "docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md"
files: 1
loc: {"added": 11, "removed": 19}
---

# refactor(jac-byllm): Simplified `_call_sync()` in jac/jaclang/byllm/parallel.jac 

## What & why

Simplified `_call_sync()` in jac/jaclang/byllm/parallel.jac to reuse the module-level `_WORKER_POOL` ThreadPoolExecutor (already defined at lines 15-17 and already used identically in `dispatch_batch` at the old line 176) instead of manually spinning up a `threading.Thread` with mutable `result_box`/`error_box` single-item lists for timeout-bounded synchronous tool calls. The new implementation submits the callable to `_WORKER_POOL` and calls `f.result(timeout=timeout)`, catching `concurrent.futures.TimeoutError` (imported as `_FutTimeoutError` to avoid shadowing the builtin `TimeoutError`) and re-raising the same `TimeoutError(f"Tool '{tc.tool.get_name()}' timed out after {timeout}s")` message the original code raised, preserving the exact exception type and message the caller (`_run_one`, which catches `(TimeoutError, asyncio.TimeoutError)`) depends on. The `timeout is None` fast path (`return tc();`) is untouched. Behavior preservation: (1) both old and new code call `tc()` with zero arguments - `ThreadPoolExecutor.submit(fn)` invokes `fn()` with no args, matching the original `_worker` closure; (2) if `tc()` raises inside the worker, the old code stashed the exception in `error_box[0]` and re-raised it after `join()` - the new code gets the identical behavior for free since `Future.result()` re-raises the worker's exception automatically; (3) on timeout, old code checked `t.is_alive()` after `join(timeout=...)` and raised `TimeoutError` with the same message - new code catches `_FutTimeoutError` from `f.result(timeout=...)` and raises the identical `TimeoutError` message. Verification performed: read `dispatch_batch` (submits to the same `_WORKER_POOL` via `_WORKER_POOL.submit(_run_one, tc)`) to confirm the pool is already used for exactly this submit/result pattern elsewhere in the file, so this isn't introducing a new dependency. Ran `mcp__jac__validate_jac` and `jac check jaclang/byllm/parallel.jac`: both report the identical 4 pre-existing `E1050 'role' parameter` errors on `ToolCallResultMsg(...)` calls (lines 76, 94, 100, 171) that are unrelated to this edit - confirmed by extracting the unmodified file via `git show HEAD:jac/jaclang/byllm/parallel.jac` into a scratch temp file (deleted immediately after, never committed) and running `jac check` on it, which produced the same 4 errors at their original (pre-edit) line numbers, proving they predate this change and are out of scope for a janitorial threading cleanup. No new errors or warnings were introduced by the diff itself (only an expected opt-in 'strip-comments' lint suggestion on the added `# ponytail:` comment, which is not enforced by default). No public signatures changed (`_call_sync` keeps the same parameters and return type), so no package-wide `jac check` beyond the single file was needed. The other two files listed in the theme scope (`parallel.impl.jac`, `impl/parallel.impl.jac`) do not exist in the repository - confirmed via `ls`, so nothing to touch there.

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/byllm/parallel.jac`

Lines: **+11 -19** (net -8).

## Verification

jac check ✓ · tests (no new failures vs baseline) ✓ · pre-commit ✓ (1 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
