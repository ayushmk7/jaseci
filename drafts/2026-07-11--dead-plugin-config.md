---
branch: "nightshift/2026-07-11/dead-plugin-config"
package: "jac-byllm"
date: "2026-07-11"
title: "refactor(jac-byllm): Removed dead class JacByllmPluginConfig (get_plugin_metadata"
risk: "low"
tests: "jac check \u2713 \u00b7 tests (no new failures vs baseline) \u2713 \u00b7 pre-commit \u2713 (4 min)"
release_note: "docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md"
files: 1
loc: {"before": 181, "after": 10}
---

# refactor(jac-byllm): Removed dead class JacByllmPluginConfig (get_plugin_metadata

## What & why

Removed dead class JacByllmPluginConfig (get_plugin_metadata/get_config_schema) from jac/jaclang/byllm/plugin_config.jac. Grep across the repo (py + jac) confirmed the class and both hooks are referenced only at their own definition site - no dispatcher, no test, no plugin loader consumes them; the live [byllm] config is read via jaclang.project.plugin_config.PluginConfigBase in config_loader.jac, against which the removed schema had drifted stale. The module itself is kept as a valid docstring-only stub because it is listed as a runtime_vendor seed (runtime_vendor.jac _BYLLM_SEEDS), which is outside this theme's allowed files; a ponytail comment records that the seed entry must be dropped to delete the file entirely. Validated with validate_jac (valid) and jac check (ok).

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/byllm/plugin_config.jac`

Net: **-171 LOC** (181 → 10).

## Verification

jac check ✓ · tests (no new failures vs baseline) ✓ · pre-commit ✓ (4 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
