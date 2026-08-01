---
branch: "nightshift/2026-07-31/dead-code-unreachable-config-fallback"
package: "repo"
date: "2026-07-31"
title: "refactor(repo): Removed three dead `or`-chain fallback reads of module-level"
risk: "low"
tests: "mirror (fmt check jir) \u2713 \u00b7 jac check \u2713 \u00b7 tests (no new failures vs baseline: byllm) \u2713 \u00b7 pre-commit \u2713 \u00b7 contribution \u2713 (1 min)"
release_note: "release_notes/unreleased/jaclang/0000.refactor.md"
files: 2
loc: {"added": 3, "removed": 9}
---

# refactor(repo): Removed three dead `or`-chain fallback reads of module-level

## What & why

Removed three dead `or`-chain fallback reads of module-level config globals that could never fire, because the globals they read from are built as whitelists that never contain the keys being looked up. In basellm.impl.jac: `_call_params_config.get("max_react_iterations")` deleted from both `_invoke_react_loop` (was line 745) and `_invoke_streaming` (was line 1629), and `_call_params_config.get("max_tool_result_length")` deleted from `_invoke_streaming` (was line 1784). I read `config_loader.impl.jac:60-75` (`get_call_params_config`) and confirmed it returns a dict containing only `max_output_retries` (always), `temperature` (only if present in jac.toml), and `max_tokens` (only if > 0) - it never copies `max_react_iterations` or `max_tool_result_length` through, so those `.get()` calls were always None and the chains fell through to their next link or the literal default (`or 0`, `or 500`) unchanged. In model.impl.jac: simplified `self.http_client = bool(self.config.get("http_client", _model_config.get("http_client", False)))` to `bool(self.config.get("http_client", False))`, and `native_override = self.config.get("native_tools", _model_config.get("native_tools"))` to `self.config.get("native_tools")`. I read `config_loader.impl.jac:48-58` (`get_model_config`) and confirmed the returned dict has exactly five keys (`default_model`, `api_key`, `base_url`, `proxy`, `verbose`) - `http_client` and `native_tools` are never in it, so those nested `.get()` calls were always dead and the outer `self.config.get(...)` default already produces identical behavior (False and None respectively). Verified `_call_params_config` and `_model_config` still have legitimate remaining call sites in both files (grepped and confirmed - e.g. `_call_params_config.get("max_output_retries"/"temperature"/"max_tokens")` at basellm.impl.jac:427,871,872, and `_model_config.get("proxy"/"api_key"/"base_url"/"verbose")` across both files), so no glob became unused. Ran `jac check` on both edited files before and after: the same ~80 (basellm.impl.jac) and ~44 (model.impl.jac) pre-existing type errors appear, all `SimpleNamespace has no attribute X` complaints from the `litellm`/`openai` optional-dependency stub types scattered across the whole file (e.g. `litellm.Timeout`, `litellm.get_model_info`) - none are new, and I grepped the check output specifically for the edited line ranges and for the tokens `max_react_iterations`, `max_tool_result_length`, `http_client`, `native_tools` and found zero errors attributable to my changes. No signatures changed (all edits are inside method bodies, same return types), so no wider `jac check` on the package was required beyond the two files. I did NOT delete `jac/jaclang/byllm/tests/fixtures/ai_agent_project/walkers.jac` from the vestigial_deletions list: I read the file and it defines a `Crawler` walker over `User`/`Post` nodes from `model.jac` in the same fixture directory, used by the unrelated `jac ai` coding-agent test suite. Grepping `test_ai_agent.jac` showed `fixture_copy()` copies this exact directory and lines 170-176 assert `"Crawler" in pm`, `"Crawler" in fw` (from `find_walkers`), and `"Crawler" in cs` (from `context_slice`) - so this file is actively load-bearing for a live test and has nothing to do with the `max_react_iterations`/`http_client`/`native_tools` config-fallback theme. This looks like a mismatched/stale vestigial_deletions entry from a different theme run; I left the file untouched per the instruction to skip when my own reading disagrees.

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/byllm/llm.impl/basellm.impl.jac`
- `jac/jaclang/byllm/llm.impl/model.impl.jac`

Lines: **+3 -9** (net -6).

## Consciously deferred

- `jac/jaclang/byllm/tests/fixtures/ai_agent_project/walkers.jac` — This file's `Crawler` walker is actively used by jac/jaclang/byllm/tests/test_ai_agent.jac (fixture_copy() + assertions at lines 170-176 checking 'Crawler' appears in prompt/find_walkers/context_slice output). It has no relationship to the max_react_iterations/http_client/native_tools config-fallback theme this run covers. Deleting it would break a live, unrelated test suite, so this vestigial_deletions entry appears mismatched for this theme; left untouched per the instruction to skip when my own reading disagrees with the harness's claim.

## Verification

mirror (fmt check jir) ✓ · jac check ✓ · tests (no new failures vs baseline: byllm) ✓ · pre-commit ✓ · contribution ✓ (1 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`release_notes/unreleased/jaclang/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
