---
branch: "nightshift/2026-07-13/dead-legacy-string-utils"
package: "jac-byllm"
date: "2026-07-13"
title: "refactor(jac-byllm): Deleted jac/jaclang/byllm/legacy_string_utils.jac, an unused"
risk: "low"
tests: "jac check \u2713 \u00b7 tests (no new failures vs baseline) \u2713 \u00b7 pre-commit \u2713 (2 min)"
release_note: "docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md"
files: 1
loc: {"before": 40, "after": 0}
---

# refactor(jac-byllm): Deleted jac/jaclang/byllm/legacy_string_utils.jac, an unused

## What & why

Deleted jac/jaclang/byllm/legacy_string_utils.jac, an unused scratch file whose own docstring admitted it held dead duplicate reverse-string and uppercase helpers never referenced anywhere in the repo (confirmed by repo-wide grep for all six function names and the module name).

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/byllm/legacy_string_utils.jac`

Net: **-40 LOC** (40 → 0).

## Verification

jac check ✓ · tests (no new failures vs baseline) ✓ · pre-commit ✓ (2 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
