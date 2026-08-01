---
branch: "nightshift/2026-07-31/dead-code-reactive-unreachable-bundle-target"
package: "repo"
date: "2026-07-31"
title: "refactor(repo): Deleted the unreachable `target == \"npm-runtime\"` branch ins"
risk: "low"
tests: "mirror (fmt check jir) \u2713 \u00b7 jac check \u2713 \u00b7 tests (no new failures vs baseline: runtime) \u2713 \u00b7 pre-commit \u2713 \u00b7 contribution \u2713 (5 min)"
release_note: "release_notes/unreleased/jaclang/0000.refactor.md"
files: 1
loc: {"added": 1, "removed": 27}
---

# refactor(repo): Deleted the unreachable `target == "npm-runtime"` branch ins

## What & why

Deleted the unreachable `target == "npm-runtime"` branch inside `impl bundle` and the now-dead `_bundle_npm_runtime` helper (22 lines) in jac/jaclang/cli/commands/impl/project.impl.jac. Confirmed dead: grepped the whole repo for `bundle(` callers - the only one is jac/jaclang/cli/commands/impl/build.impl.jac:68, which is gated one line earlier by `if projection in ["jab", "sealed", "binary", "wheel", "npm"]`, so target can never be "npm-runtime" at that call site. Checked the CLI-facing surface too: jac/jaclang/cli/commands/build.jac declares target choices as [jab, sealed, binary, wheel, npm, source, native] and the generated manifest (jac/jaclang/cli/impl/manifest.impl.jac) repeats the same list - npm-runtime is absent from both, meaning no CLI invocation path can reach this branch either. Repo-wide grep for the literal npm-runtime after the edit shows only two remaining unrelated hits (a release-notes doc line and jac/jaclang/publish/impl/runtime_npm.impl.jac, which defines the still-used `build_runtime_to`/`runtime_pkg_name` functions consumed elsewhere - not in this theme's file list, left untouched). The `bundle()` function signature in jac/jaclang/cli/commands/project.jac is unchanged (target: str = "wheel" as before), so no downstream signature-change ripple; that file needed no edits since only the impl body's dead branch/helper were removed. Verified with `jac check` on both project.jac and project.impl.jac: the run reports 56 pre-existing errors/146 warnings, all of them anchored to unrelated code (install/remove/update param handling, `config: any` typed helpers, DependencyPlan/bool mismatches) at line numbers far from the edited region (2086-2113 post-edit); grepped the check output specifically for line numbers in and around the new `impl bundle` body (2086-2101) and found zero errors there, confirming no regression was introduced. Ran `git commit`, which triggers the repo's pre-commit lintfix/formatter hook - it reformatted whitespace only (no semantic change) and reported the same pre-existing warning set (too-many-params, mutable-default, unnecessary-else-after-return) on unrelated functions; commit succeeded clean.

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/cli/commands/impl/project.impl.jac`

Lines: **+1 -27** (net -26).

## Verification

mirror (fmt check jir) ✓ · jac check ✓ · tests (no new failures vs baseline: runtime) ✓ · pre-commit ✓ · contribution ✓ (5 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`release_notes/unreleased/jaclang/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
