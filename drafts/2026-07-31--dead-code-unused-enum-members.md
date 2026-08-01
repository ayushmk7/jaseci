---
branch: "nightshift/2026-07-31/dead-code-unused-enum-members"
package: "repo"
date: "2026-07-31"
title: "refactor(repo): Deleted 19 never-referenced members from the `CompletionItem"
risk: "low"
tests: "mirror (fmt check jir) \u2713 \u00b7 jac check \u2713 \u00b7 tests (no new failures vs baseline: compiler) \u2713 \u00b7 pre-commit \u2713 \u00b7 contribution \u2713 (5 min)"
release_note: "release_notes/unreleased/jaclang/0000.refactor.md"
files: 1
loc: {"added": 1, "removed": 19}
---

# refactor(repo): Deleted 19 never-referenced members from the `CompletionItem

## What & why

Deleted 19 never-referenced members from the `CompletionItemKind` enum in jac/jaclang/compiler/type_system/type_utils.jac (lines 58-84 before, 58-65 after), leaving only the 6 kinds the compiler actually emits: Text=1, Function=3, Variable=6, Class=7, Module=9, Enum=13. Removed: Method, Constructor, Field, Interface, Property, Unit, Value, Keyword, Snippet, Color, File, Reference, Folder, EnumMember, Constant, Struct, Event, Operator, TypeParameter. Crucially the surviving members KEEP their original explicit integer literals (the enum was already fully explicit, `Text = 1` .. `TypeParameter = 25`), so the wire values sent to LSP clients are byte-identical and remain aligned with the LSP CompletionItemKind spec; the enum is now sparse (1,3,6,7,9,13) rather than renumbered. Verification: (1) Repo-wide Grep for `CompletionItemKind` returned exactly 11 hits. Six are the returns in type_system/impl/type_utils.impl.jac:306-321 inside `completion_kind_from_sym`, whose match arms map ModulePath->Module, Ability->Function, Archetype->Class, Enum->Enum, HasVar->Variable, with a Text fallback - precisely the 6 I kept. The two hits in langserve/impl/engine.impl.jac:611 (`lspt.CompletionItemKind.Keyword`) and tests/compiler/passes/tool/fixtures/tagbreak.jac:130 (`lspt.CompletionItemKind.Variable`) are qualified with the `lspt.` prefix and resolve to the SEPARATE enum declared at jac/jaclang/lsp/types.jac:62, which I did not touch; the remaining hits are that enum's own declaration and its use as a parameter annotation at lsp/types.jac:275. So Keyword surviving in the lsp/types.jac enum is what engine.impl.jac needs, and nothing reads the deleted members from the type_system copy. (2) Ran `jac check` on type_utils.jac and types.jac plus both impl/ companions before and after the edit by literally reverting the enum with the editor and re-running. Diagnostic counts are identical pre/post: type_utils.jac 15 errors / 30 warnings, types.jac 7 errors / 20 warnings. All 15 errors are pre-existing and unrelated to this change (E1030 get_type_evaluator, E1032, E1053 iterable/Sized on Optional lists, E1099 names_in_scope on Optional, and six E1002 'Cannot return <CompletionItemKind.X>, expected int' that fire on the SURVIVING members because `completion_kind_from_sym` is declared `-> int`; those six existed identically before my edit). An earlier draft added a two-line explanatory comment above the enum, which raised warnings from 30 to 32 by tripping the opt-in `strip-comments` W3050 rule, so I removed the comment to hold exact warning parity. (3) Tests: `jac test tests/compiler/passes/main/test_checker_pass.jac` -> 238 passed. `jac test tests/langserve/test_server.jac` -> 31 passed (this is the suite that exercises the completion path end to end). `jac test tests/compiler/` -> 2570 passed, 61 skipped, 2 failed; I confirmed both failures (test_importer.jac 'release compile closure clears ASTs and evaluator but keeps stubs' and passes/native/test_native_bytes_struct.jac 'bytes membership is length-aware (#6749)') reproduce identically with my edit fully reverted, so they are pre-existing and unrelated. (4) `jac fmt --check` on the file produced no modification (git status clean after). The second finding, TypeCategory.Unbound, was SKIPPED - see `skipped` for the concrete test that breaks. Committed with subject only, no trailer of any kind.

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/compiler/type_system/type_utils.jac`

Lines: **+1 -19** (net -18).

## Consciously deferred

- `jac/jaclang/compiler/type_system/types.jac` — Deleting `TypeCategory.Unbound` ripples outside the theme's allowed file list. The finding's own risk note was about IntEnum ordinal shifts, and I cleared that concern: `category` is a computed getter (impl/types.impl.jac:454 returns `self.CATEGORY`, a ClassVar), never a stored ordinal, and the JIR serializer only persists the unrelated `SymbolType` enum by string value (jac0core/impl/jir_passes.impl.jac:603,1129), so no ordinal is written to disk. The blocker is different and concrete: removing the line shifts every subsequent line in types.jac by one, and tests/langserve/test_server.jac::test_go_to_definition_md_path asserts a hardcoded source location. I actually ran it and got `AssertionError: Line 18, char 5: expected 'compiler/type_system/types.jac:38:4-38:12' in '...types.jac:37:4-37:12'`. Fixing that means editing tests/langserve/test_server.jac, which is not in the theme's file list, so per the harness rules I reverted rather than produce a diff that gets discarded. I also could not leave a `# ponytail:` marker in place: adding comment lines shifts the same line numbers and breaks the same assertion, so types.jac is byte-identical to HEAD.
- `jac/jaclang/byllm/tests/test_multimodal_tool_results.jac` — Listed in vestigial_deletions, but my own reading disagrees, so I left it alone as instructed. Grepped the file for both `CompletionItemKind` and `TypeCategory`: zero matches. It is a byllm multimodal tool-result test with no connection to either enum in this theme, so there is no basis for me to git rm it.
- `jac/tests/compiler/passes/main/fixtures/checker/checker_function_attrs.jac` — Listed in vestigial_deletions, but my reading disagrees. Zero matches for `CompletionItemKind` or `TypeCategory`; the file is a 14-line fixture testing `Callable.__code__` / `__name__` / `__module__` attribute access. It is also still live: tests/compiler/passes/main/test_checker_pass.jac:3405 loads it by name, and that test file is outside my allowed list so I could not remove the reference. Deleting it would break a currently-passing test (I ran that suite: 238 passed).
- `jac/tests/compiler/passes/main/fixtures/checker/checker_runtime_errors.jac` — Listed in vestigial_deletions, but my reading disagrees. Zero matches for `CompletionItemKind` or `TypeCategory`. Still referenced by five live assertions in tests/compiler/passes/main/test_checker_pass.jac (lines 3757, 3782, 3802, 3822, 3843), all of which pass today; removing the fixture would break them and I may not edit that test file.

## Verification

mirror (fmt check jir) ✓ · jac check ✓ · tests (no new failures vs baseline: compiler) ✓ · pre-commit ✓ · contribution ✓ (5 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`release_notes/unreleased/jaclang/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
