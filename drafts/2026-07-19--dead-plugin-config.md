---
branch: "nightshift/2026-07-19/dead-plugin-config"
package: "jac-byllm"
date: "2026-07-19"
title: "refactor(jac-byllm): Deleted jac/jaclang/byllm/plugin_config.jac in full (169 lin"
risk: "low"
tests: "jac check \u2713 \u00b7 tests (no new failures vs baseline) \u2713 \u00b7 pre-commit \u2713 (1 min)"
release_note: "docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md"
files: 1
loc: {"added": 1, "removed": 169}
---

# refactor(jac-byllm): Deleted jac/jaclang/byllm/plugin_config.jac in full (169 lin

## What & why

Deleted jac/jaclang/byllm/plugin_config.jac in full (169 lines). It defined class JacByllmPluginConfig with static methods get_plugin_metadata() and get_config_schema(), duplicating the byllm config schema by hand. Verified dead: repo-wide grep for `JacByllmPluginConfig` (case-sensitive, all .jac/.py files) matched only the class's own definition line, zero call sites anywhere including byllm's own tests. Grepped for `.get_config_schema(` / `.get_plugin_metadata(` and confirmed every call site targets the unrelated JacMcpPluginConfig class in jac/tests/cli/test_mcp.jac, not this one. The real, live byllm config path is JacByllmConfig / get_byllm_config() in config_loader.jac + impl/config_loader.impl.jac, which is what llm.jac, basellm.impl.jac, mtir.impl.jac, and cli/impl/ai_agent.impl.jac actually import. The other two files named in the theme (plugin_config.impl.jac and impl/plugin_config.impl.jac) do not exist on disk (confirmed via `find jac/jaclang/byllm -iname '*plugin_config*'`, which returned only the one file) - nothing to touch there. One residual reference: jac/jaclang/publish/runtime_vendor.jac still lists 'jaclang.byllm.plugin_config' in _BYLLM_SEEDS, but that file is outside the allowed edit scope for this theme. I read its resolution logic (_module_to_file returns None for a missing path, and the vendoring queue loop does `if src_file is None { continue; }`) and confirmed a missing seed module is silently skipped, not an error - so the dangling seed entry is inert dead weight, not a functional break. Also grepped 'byllm.plugin_config' repo-wide: the only other hit is jac/tests/project/test_pkg_config.jac, which uses the literal string 'byllm.plugin_config:Config' purely as TOML fixture data for testing generic entrypoint-string parsing (different package namespace, not a real import of the deleted module) - unrelated and untouched.

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/byllm/plugin_config.jac`

Lines: **+1 -169** (net -168).

## Consciously deferred

- `jac/jaclang/byllm/plugin_config.impl.jac` — file does not exist on disk; nothing to edit or delete
- `jac/jaclang/byllm/impl/plugin_config.impl.jac` — file does not exist on disk; nothing to edit or delete

## Verification

jac check ✓ · tests (no new failures vs baseline) ✓ · pre-commit ✓ (1 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
