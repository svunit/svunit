---
name: release-new-version
description: 'Release a new version of SVUnit. Use when: cutting a release, bumping the version number, tagging a release, publishing a new version. Covers the full release workflow: pre-release PR, GitHub Web UI steps, and post-release PR.'
argument-hint: 'Version number to release, e.g. 3.39.0'
---

# Release a New Version of SVUnit

## Overview

A release involves the following phases:
1. **Pre-release PR** (local) — update version numbers and CHANGELOG
2. **Merge pre-release PR** (web UI) — create and merge the PR
3. **Create annotated tag** (local) - create annotated tag and push it
4. **Create the GitHub release** (web UI) — draft and publish the release on GitHub
5. **Post-release PR** (local) — reset to `Unreleased` state for continued development
6. **Merge post-release PR** (web UI) — create and merge the PR

Determine the new version number using [Semantic Versioning](https://semver.org/spec/v2.0.0.html) based on what changed since the last release. Check the current `## [Unreleased]` section in `CHANGELOG.md` to decide: breaking changes → major, new features → minor, bug fixes only → patch.

---

## Phase 1 — Pre-release PR (local)

### 1.1 Find the previous version

The previous version is the topmost versioned heading in `CHANGELOG.md` (below `## [Unreleased]`), and also appears in the `[Unreleased]` comparison link at the bottom of the file:

```
[Unreleased]: https://github.com/svunit/svunit/compare/v<PREV>...HEAD
```

### 1.2 Create the release branch

```bash
git checkout -b release-version-<NEW_VERSION>
```

### 1.3 Edit `CHANGELOG.md`

Two changes are needed:

**a) Replace the `[Unreleased]` heading** with the new versioned heading (use today's date):

```diff
-## [Unreleased]
+## [<NEW_VERSION>] - <YYYY-MM-DD>
```

**b) Replace the `[Unreleased]` comparison link** at the bottom of the file:

```diff
-[Unreleased]: https://github.com/svunit/svunit/compare/v<PREV>...HEAD
+[<NEW_VERSION>]: https://github.com/svunit/svunit/compare/v<PREV>...v<NEW_VERSION>
```

### 1.4 Edit `svunit_base/svunit_version_defines.svh`

```diff
-`define SVUNIT_VERSION Unreleased
+`define SVUNIT_VERSION <NEW_VERSION>
```

### 1.5 Commit and push

```bash
git add CHANGELOG.md svunit_base/svunit_version_defines.svh
git commit -m "Update version number"
git push -u origin release-version-<NEW_VERSION>
```

### 1.6 Open the PR

Open a pull request on GitHub with:
- **Base branch**: `master`
- **Head branch**: `release-version-<NEW_VERSION>`
- **Title**: `Release version <NEW_VERSION>`

---

## Phase 2 — Merge pre-release PR (web UI)

On GitHub, merge the pull request created in Phase 1.
Do not continue until the merge commit is on `master` and the PR is fully merged.

## Phase 3 — Create annotated tag (local)

> Note: this repository requires an *annotated* tag. GitHub's web UI may create a lightweight tag when drafting a release; create and push an annotated tag from your local machine before publishing the release to ensure the tag is annotated.

1. Update local `master` to the merge commit and tag `HEAD`.

```bash
# ensure master is up to date and points at the merge commit
git checkout master
git pull
```

The annotated tag should be created on `master`'s `HEAD` (the merge commit). If you prefer tagging before the PR is merged, create the tag on the release branch tip instead.

2. Create an annotated tag and push it:

```bash
# create an annotated tag pointing at the desired commit (use the commit hash or HEAD)
git tag -a v<NEW_VERSION> -m "Release v<NEW_VERSION>" <COMMIT>
git push origin v<NEW_VERSION>
```

## Phase 4 — Create the GitHub release (web UI)

1. Go to **Releases** → **Draft a new release**
2. **Tag**: `v<NEW_VERSION>` — set it to target `master` (the merge commit)
3. **Release title**: `<NEW_VERSION>`
4. **Description**: paste the content of the `## [<NEW_VERSION>]` section from `CHANGELOG.md`
5. Publish the release

---

## Phase 5 — Post-release PR (local)

### 5.1 Create the post-release branch

```bash
git checkout master
git pull
git checkout -b continue-development-after-releasing-version-<NEW_VERSION>
```

### 5.2 Edit `svunit_base/svunit_version_defines.svh`

```diff
-`define SVUNIT_VERSION <NEW_VERSION>
+`define SVUNIT_VERSION Unreleased
```

### 5.3 Edit `CHANGELOG.md`

Two changes are needed:

**a) Add a new `[Unreleased]` section** at the top (after the file header, before the released version):

```diff
+## [Unreleased]
+
+
+## [<NEW_VERSION>] - <YYYY-MM-DD>
```

**b) Add the `[Unreleased]` comparison link** at the top of the links section at the bottom of the file:

```diff
+[Unreleased]: https://github.com/svunit/svunit/compare/v<NEW_VERSION>...HEAD
 [<NEW_VERSION>]: https://github.com/svunit/svunit/compare/v<PREV>...v<NEW_VERSION>
```

### 5.4 Commit and push

```bash
git add svunit_base/svunit_version_defines.svh
git commit -m "Clear version info from code"
git add CHANGELOG.md
git commit -m "Add entry for unreleased version to CHANGELOG"
git push -u origin continue-development-after-releasing-version-<NEW_VERSION>
```

### 5.5 Open the PR

Open a pull request on GitHub with:
- **Base branch**: `master`
- **Head branch**: `continue-development-after-releasing-version-<NEW_VERSION>`
- **Title**: `Continue development after releasing version <NEW_VERSION>`

## Phase 6 — Merge post-release PR (web UI)

On GitHub, merge the pull request created in Phase 5.
