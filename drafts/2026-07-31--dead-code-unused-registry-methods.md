---
branch: "nightshift/2026-07-31/dead-code-unused-registry-methods"
package: "repo"
date: "2026-07-31"
title: "refactor(repo): Deleted two dead public methods flagged by the theme, both c"
risk: "low"
tests: "mirror (fmt check jir) \u2713 \u00b7 jac check \u2713 \u00b7 tests (no new failures vs baseline: runtime) \u2713 \u00b7 pre-commit \u2713 \u00b7 contribution \u2713 (2 min)"
release_note: "release_notes/unreleased/jaclang/0000.refactor.md"
files: 3
loc: {"added": 1, "removed": 15}
---

# refactor(repo): Deleted two dead public methods flagged by the theme, both c

## What & why

Deleted two dead public methods flagged by the theme, both confirmed via repo-wide grep to have zero callers before touching anything. (1) `TemplateRegistry.is_empty` and `TemplateRegistry.clear` (declared jac/jaclang/project/template_registry.jac:27-28, implemented jac/jaclang/project/impl/template_registry.impl.jac:107-113): grepped `.is_empty()` and `registry.clear()` repo-wide, every `is_empty()` hit resolves to `DependencyPlan.is_empty`, `CapabilityClosure.is_empty`, `Changeset.is_empty`, or `SchemaRules.is_empty` (all unrelated types), and the one `registry.clear()` call (jac/tests/runtimelib/client/test_react_native_target.jac:28) targets the unrelated client target registry, not `TemplateRegistry`. (2) `ProviderRegistry.clear` (jac/jaclang/project/providers.jac:606-609, single-file with impl inline, no separate providers.impl.jac exists): same grep sweep shows no `registry.clear()` call targeting the provider registry; test teardown uses `reset_provider_registry()` (providers.jac:631, unchanged) which nulls the singleton instead, so the live reset path was left intact. Also inspected jac/tests/cli/test_shadcn_create.jac, listed under vestigial_deletions, but its only registry references are `get_template_registry`, `initialize_template_registry`, `registry.get`, and `registry.get_by_kind` -- none of which are the symbols this theme deletes, and the `jaclang.cli.shadcn.cli.register_project_template` hook it exercises still exists and is unrelated to this change -- so I left that file untouched and recorded it in `skipped` rather than deleting it. Verification: ran `jac check` on both edited source files individually (0 errors each, only pre-existing W1037/W1103/W3036 style warnings unrelated to the deletions) and on the whole `jaclang/project/` package -- the only failing files (`template_loader.jac`, `config.jac` and their impls) have errors unrelated to and pre-existing before this change (files never touched by this diff). `git diff --stat` confirms only the 3 intended files changed, 15 lines removed, 0 added, nothing added elsewhere. Commit is clean with only the same pre-existing mutable-default-argument warnings surfaced by the repo's pre-commit hook (not introduced by this change).

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/project/template_registry.jac`
- `jac/jaclang/project/impl/template_registry.impl.jac`
- `jac/jaclang/project/providers.jac`

Lines: **+1 -15** (net -14).

## Consciously deferred

- `jac/tests/cli/test_shadcn_create.jac` — Listed under vestigial_deletions, but its only references to the registry module are get_template_registry, initialize_template_registry, registry.get, and registry.get_by_kind -- none of which are is_empty or clear, the symbols this theme deletes. The shadcn cli hook it exercises (jaclang.cli.shadcn.cli.register_project_template) is untouched and still live. My reading disagrees with the harness's pre-confirmation, so per the hard rule I left the file alone instead of git rm'ing it.

## Verification

mirror (fmt check jir) ✓ · jac check ✓ · tests (no new failures vs baseline: runtime) ✓ · pre-commit ✓ · contribution ✓ (2 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`release_notes/unreleased/jaclang/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
