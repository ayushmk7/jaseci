---
branch: "nightshift/2026-07-31/dead-code-reactive-unused-registry-api"
package: "repo"
date: "2026-07-31"
title: "refactor(repo): Removed two dead methods from CommandRegistry: has_command(n"
risk: "low"
tests: "mirror (fmt check jir) \u2713 \u00b7 jac check \u2713 \u00b7 tests (no new failures vs baseline: runtime) \u2713 \u00b7 pre-commit \u2713 \u00b7 contribution \u2713 (2 min)"
release_note: "release_notes/unreleased/jaclang/0000.refactor.md"
files: 2
loc: {"added": 1, "removed": 15}
---

# refactor(repo): Removed two dead methods from CommandRegistry: has_command(n

## What & why

Removed two dead methods from CommandRegistry: has_command(name) and get_groups(). Deleted the declarations at jac/jaclang/cli/registry.jac:19 and :24, and their implementations at jac/jaclang/cli/impl/registry.impl.jac (has_command at old line 37, get_groups at old line 53). Confirmed dead via repo-wide grep for 'has_command' (only hits: the declaration and the impl, no call site in any .jac/.py/test file) and for 'get_groups' (all remaining hits belong to an unrelated module-level get_groups in jac/jaclang/cli/manifest.jac:83, implemented in manifest.impl.jac and consumed only by mcp_manifest.impl.jac:9 - none reach CommandRegistry.get_groups). The sibling method get_all was left untouched since it is genuinely called from jac/jaclang/cli/gen_cli_manifest.jac:54. Verified with `jac check jaclang/cli/registry.jac` (1 passed, only a pre-existing unrelated W1103 warning about Callable import) and `jac check jaclang/cli/` across the whole package: registry.jac, impl/registry.impl.jac, manifest.jac, impl/manifest.impl.jac, gen_cli_manifest.jac, mcp_manifest.jac all report 'ok' with 0 errors post-edit. The 48 failing files in that package-wide run are pre-existing, unrelated shadcn/mcp template errors, confirmed unaffected by grepping the failure list for 'registry'/'manifest'/'gen_cli' - none appear. Pre-commit hook ran formatting only, no typecheck gate, and passed cleanly.

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/cli/registry.jac`
- `jac/jaclang/cli/impl/registry.impl.jac`

Lines: **+1 -15** (net -14).

## Verification

mirror (fmt check jir) ✓ · jac check ✓ · tests (no new failures vs baseline: runtime) ✓ · pre-commit ✓ · contribution ✓ (2 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`release_notes/unreleased/jaclang/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
