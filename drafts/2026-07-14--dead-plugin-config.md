---
branch: "nightshift/2026-07-14/dead-plugin-config"
package: "jac-scale"
date: "2026-07-14"
title: "refactor(jac-scale): Deleted jac/jaclang/scale/config/plugin_config.jac in full ("
risk: "low"
tests: "jac check \u2713 \u00b7 tests (no new failures vs baseline) \u2713 \u00b7 pre-commit \u2713 (2 min)"
release_note: "docs/docs/community/release_notes/unreleased/jac-scale/0000.refactor.md"
files: 1
loc: {"added": 1, "removed": 492}
---

# refactor(jac-scale): Deleted jac/jaclang/scale/config/plugin_config.jac in full (

## What & why

Deleted jac/jaclang/scale/config/plugin_config.jac in full (492 lines). The file defined a single class, JacScalePluginConfig, with two static methods (get_plugin_metadata, get_config_schema) that returned a large hand-maintained nested dict re-describing every config default already declared authoritatively in jac/jaclang/scale/config/impl/config_loader.impl.jac's get_default_config(). Verification: grepped the whole repo for the literal symbol 'JacScalePluginConfig' and the only hit was its own class declaration line in the file being deleted - no import, instantiation, or call site anywhere, including test files. Also grepped jac/jaclang/scale/ for 'plugin_config' more broadly; the only remaining hits are unrelated - config_loader.jac imports PluginConfigBase from jaclang.project.plugin_config (a different, unrelated base class in the project/ package, not scale/config/), and config_loader.impl.jac calls get_plugin_config() (a runtime method on a config object, unrelated by name only). Confirmed the two other file paths listed in the theme (plugin_config.impl.jac and config/impl/plugin_config.impl.jac) do not exist in the repo via Glob, so there was nothing else to touch. No signature changes occurred (whole file deleted, zero external references), so no jac check was required beyond the reference-site grep already performed.

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/scale/config/plugin_config.jac`

Lines: **+1 -492** (net -491).

## Consciously deferred

- `jac/jaclang/scale/config/plugin_config.impl.jac` — file does not exist in repo
- `jac/jaclang/scale/config/impl/plugin_config.impl.jac` — file does not exist in repo

## Verification

jac check ✓ · tests (no new failures vs baseline) ✓ · pre-commit ✓ (2 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`docs/docs/community/release_notes/unreleased/jac-scale/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
