# Release management

A release tag identifies an immutable, versioned source snapshot. GitHub Actions builds native and
Arm archive artifacts from that tag and can replace those assets when the same workflow is rerun.
The repository uses `version.txt` as its single version source and verifies that the tag, generated
metadata, and package names agree.

## Version contract

`version.txt` must contain exactly one value in this form:

```text
vMAJOR.MINOR.PATCH
```

CMake validates the file during configuration. It keeps the tag form for documentation and removes
the leading `v` where a numeric version is required by `project(VERSION)`, the generated C++ header,
installed CMake package compatibility file, CPack, and Conan. The executable's `--version` output
uses the numeric form.

Use semantic-version intent when choosing the next value:

- increment **MAJOR** for an incompatible public API, ABI, package, or supported-usage change;
- increment **MINOR** for backward-compatible functionality; and
- increment **PATCH** for backward-compatible corrections.

For a C++ library, source compatibility and binary compatibility are separate concerns. Changes to
public type layout, virtual functions, symbol names, inline behavior, compiler ABI, standard
library, or build options can require a major release even when a caller's source still compiles.
Embedded products should also consider configuration, persistent data, IPC, update, and rollback
compatibility.

## Prepare a release candidate

1. Confirm the intended changes are merged and the working tree contains no generated artifacts.
2. Update `version.txt` to the final tag value.
3. Move the release notes from `Unreleased` into a dated version section, leave an empty
   `Unreleased` section for subsequent work, and update the changelog comparison links.
4. Run the full native verification:

   ```console
   make format-check
   make check
   make test PRESET=ci
   make sanitize
   make coverage
   make docs
   ```

5. Build and inspect the native installation and archive:

   ```console
   make package
   make consumer-test
   ```

6. Run both cross-builds and validate on representative target hardware:

   ```console
   make cross-arm64
   make cross-armv7
   ```

7. Record the exact host compilers, SDK or sysroot, emulator, devices, commands, and results in the
   release review.

Only claim checks that actually ran. A generic GNU cross-build and QEMU startup are useful
portability gates but cannot qualify a production board.

## Create the tag

Commit the version and changelog changes through the normal pull-request process. After the release
commit is on `main`, create an annotated tag whose name exactly matches `version.txt`:

```console
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin v0.1.0
```

Replace the example with the actual version. Tagging is a publishing action: verify the commit and
version before pushing. Do not reuse a published version for different contents.

The workflow can also be started manually with an existing `vMAJOR.MINOR.PATCH` tag. Manual dispatch
does not create a missing tag and does not bypass version validation.

## Automated release workflow

`.github/workflows/release.yml` performs these gates in order:

1. Validate the requested tag as `vMAJOR.MINOR.PATCH`.
2. Check out that exact tag and require `version.txt` to match it.
3. Build and test the strict native `ci` preset.
4. Produce native, AArch64, and Armv7 CPack archives.
5. Stage the native install and build the independent downstream CMake consumer.
6. Require each archive filename to contain the numeric version.
7. Collect the archives and generate a `SHA256SUMS` manifest.
8. Verify the manifest before uploading a workflow artifact.
9. Create the GitHub release, or replace its assets when rerunning an existing release.

The publishing job alone receives `contents: write`; build jobs remain read-only. If an early gate
fails, no GitHub release is published.

## Release artifacts

The release contains three portable `.tar.gz` archives plus `SHA256SUMS`:

- a native release package built on the GitHub-hosted Linux runner;
- an AArch64 GNU/Linux package; and
- an Armv7 GNU/Linux hard-float package.

CPack strips archive binaries, while the local `RelWithDebInfo` cross-build trees retain debug
information for diagnosis. Preserve reproducible symbols or create a controlled symbol archive in
a derived production repository when post-release debugging requires it.

Consumers should verify the downloaded artifacts from the directory containing the manifest:

```console
sha256sum --check SHA256SUMS
```

A checksum detects accidental corruption and substitution relative to the manifest; it is not a
cryptographic identity for the publisher. Products that require authenticated updates should add
artifact signing, protected signing identities, provenance, and device-side verification.

## After publication

- Verify the GitHub release contains every expected archive and a valid checksum manifest.
- Install or unpack an artifact in a clean environment and run a smoke test.
- Confirm documentation shows the released version and the changelog is readable.
- Record target-device results and known limitations.
- Record post-release changes under the empty `Unreleased` changelog heading.

If a released defect is found, publish a new patch version. Deleting or replacing a public tag can
invalidate downstream source locks and audit trails; reserve that operation for an explicitly
documented recovery from a failed or unauthorized release.

## Derived-project responsibilities

The generic TGZ archives do not define a complete device update. A production repository should
add the target distribution's package or image integration, supported upgrade paths, service
coordination, configuration migration, rollback, signed metadata, software bill of materials, and
retention policy. Review {doc}`security` and {doc}`cross-compiling` before enabling automatic device
deployment.
