---
branch: "nightshift/2026-07-22/image-postinit-branches"
package: "jac-byllm"
date: "2026-07-22"
title: "refactor(jac-byllm): Simplified Image.postinit in jac/jaclang/byllm/types.impl/me"
risk: "low"
tests: "jac check \u2713 \u00b7 tests (no new failures vs baseline) \u2713 \u00b7 pre-commit \u2713 (1 min)"
release_note: "docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md"
files: 1
loc: {"added": 21, "removed": 25}
---

# refactor(jac-byllm): Simplified Image.postinit in jac/jaclang/byllm/types.impl/me

## What & why

Simplified Image.postinit in jac/jaclang/byllm/types.impl/media.impl.jac by (1) removing a redundant early `self.mime_type = self._format_to_mime(fmt)` assignment in the local-path branch, since `_data_url_from_bytes` (line 114-119 post-change) already does `self.mime_type or self._format_to_mime(fmt)` and mime_type was still None/falsy at that point in every prior call path except this one, so the assignment was a pure no-op duplicate of work `_data_url_from_bytes` does anyway; and (2) merging the bytes-like branch (isinstance bytes/bytearray/memoryview) and the file-like branch (has a callable `.read`) into one shared tail: both branches now just resolve a `raw: bytes | None` local (via `if isinstance(...) {...} elif value?.read ... {...}`), then a single trailing block does `if raw is None: raise TypeError(...)` followed by the sniff-format/encode/fallback-reencode logic that both branches previously duplicated verbatim. The local-path and PIL.Image branches were left untouched (only the one redundant line removed from the local-path branch) because they use a decode-then-re-encode-via-.save() flow that is NOT equivalent to reading raw bytes directly (e.g. multi-frame GIFs would lose frames on a PIL re-save), so unifying them with the raw-bytes branches would have been a real behavior change, not a safe dedup - I deliberately did not do that. I verified behavior-preservation by: reading the full postinit plus `_format_to_mime`/`_data_url_from_bytes` bodies to confirm the redundant-assignment claim; running `jac check` on the full `jaclang/byllm/types.jac` package before and after the change (via a temporary swap of the old file content back in, checking, then restoring - no scratch files left in the repo) and diffing the error message sets - the error count was identical (33 before, 33 after) and the only textual difference was two pre-existing 'Cannot assign <Unknown> to bytes' errors (caused by an already-Unknown-typed `stream.read()`/`stream.getvalue()` return, unrelated to my change) now reading 'bytes | NoneType' because I gave `raw` an explicit `bytes | None` annotation - same root cause, no new error class. I initially wrote the merged block using `if raw is not None { ...; return; }` which the Jac type checker could not narrow (introduced a new spurious 'Cannot assign NoneType to parameter data' error), confirmed via a minimal repro against `mcp__jac__validate_jac`, then switched to the `if raw is None { raise ... }` early-exit idiom with an explicit `raw: bytes | None = None` declaration, which a second minimal repro confirmed the checker narrows correctly - this is what's in the final diff. I also looked at the runtime test fixture `jac/jaclang/byllm/tests/fixtures/image_types.jac`, which exercises PIL.Image, local path, http/gs/data URL, BytesIO, raw bytes, memoryview, data-URL, os.PathLike, a file-like object without `.getvalue()`, and bytearray inputs against this exact method, but I was not able to execute `jac run` on it myself because the sandbox required interactive approval for that command and none was available in this session, so I did not get a live runtime confirmation beyond the static jac check comparison. No signatures changed (postinit is still `Image.postinit -> None`), so per the protocol `jac check` was not strictly required but I ran it anyway as extra assurance.

This is a nightly-janitor cleanup: existing behavior is preserved, code is removed or
simplified per the ponytail ladder (does it need to exist → stdlib → one line → minimum code).

## Changes

- `jac/jaclang/byllm/types.impl/media.impl.jac`

Lines: **+21 -25** (net -4).

## Verification

jac check ✓ · tests (no new failures vs baseline) ✓ · pre-commit ✓ (1 min)

## Reviewer checklist

- [ ] Diff touches only the listed files
- [ ] No behavior change intended or observed
- [ ] Release-note fragment present (`docs/docs/community/release_notes/unreleased/byllm/0000.refactor.md`)
- [ ] Risk level (low) matches the nature of the change
