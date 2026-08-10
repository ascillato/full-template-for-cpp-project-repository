# Contributing

Contributions should keep the template portable across projects, reproducible on supported hosts,
and useful beyond one private board or SDK. The repository-root
[`CONTRIBUTING.md`](https://github.com/ascillato/full-template-for-cpp-project-repository/blob/main/CONTRIBUTING.md)
is the authoritative contribution policy; this page connects that policy to the detailed guides in
this site.

Participation is governed by {doc}`code-of-conduct`. Suspected vulnerabilities follow the private
process in {doc}`security`, not a public issue or pull request.

## Before starting

- Search open issues, discussions, and pull requests for related work.
- Discuss large architecture, compatibility, dependency, or workflow changes before implementation.
- Keep board-specific features outside the generic template unless they are optional examples with
  a clear portability boundary.
- Base conclusions on the actual compiler, preset, SDK, sysroot, emulator, and device involved.

Use GitHub Discussions for adaptation and setup questions. Use the issue forms for reproducible
template defects or scoped generic enhancements; {doc}`support` explains what diagnostic context to
provide.

## Set up the development environment

The checked-in development container is the recommended complete environment. In Visual Studio
Code, open `Embedded-Linux-Template.code-workspace`, then run **Dev Containers: Reopen in
Container**.

On Debian or Ubuntu, `make setup-native` installs the full host toolchain explicitly. On other
Linux distributions, install equivalent C++20, CMake 3.25+, Ninja, analysis, documentation, and
cross-compilation tools. See {doc}`development` and {doc}`tooling` for details.

## Make a focused change

- Public declarations belong below `include/embedded_linux_template/`.
- Reusable implementations belong in `src/`.
- Process startup and command-line handling belong in `app/`.
- Test helpers and fixtures remain in `tests/`.
- Compiler features, warnings, definitions, includes, and dependencies should be target-scoped.
- Generated output below `build/` must not be edited or committed.

Preserve the C++20 and CMake 3.25 baselines unless the contribution intentionally changes the
compatibility contract. Avoid assumptions about libc, CPU width, byte order, init system,
filesystem layout, hardware, or vendor SDK that are not represented by an explicit target
interface.

Public APIs require Doxygen comments that describe parameters, results, failure behavior, units,
ownership, and meaningful Linux assumptions. Behavioral changes require tests and user-facing
documentation. See {doc}`architecture`, {doc}`testing`, and {doc}`documentation`.

## Verify the change

For the routine native path, run:

```console
make format
make format-check
make check
make test
make docs
```

Add the checks that match the risk:

- use `make sanitize` for memory ownership, buffers, casts, or undefined-behavior-sensitive code;
- use `make coverage` to inspect whether new branches and errors have meaningful tests;
- use `make consumer-test` for installed headers, exports, or link-interface changes;
- use `make package` for installation or distribution changes; and
- use `make cross-arm64` and `make cross-armv7` for target-sensitive C++ or CMake changes.

Cross compilation does not replace execution on representative devices. If a compiler, emulator,
or board was unavailable, record the skipped check and prerequisite explicitly instead of marking
it as passed. {doc}`continuous-integration` explains the automated matrix.

## Tests and documentation

Prefer tests of observable behavior and deterministic library interfaces. Unit tests must not
depend on a contributor's hostname, kernel, locale, network, wall clock, or hardware. CLI behavior
such as options, output markers, version, and exit status belongs in CTest integration coverage.

Update the relevant guide when commands, presets, outputs, deployment behavior, supported targets,
or requirements change. Update {doc}`api` through comments on public declarations. Add every
user-visible change to the `Unreleased` section of {doc}`changelog`.

## Pull request expectations

A pull request should:

1. explain the problem and why the chosen change is needed;
2. keep unrelated formatting or refactoring out of the patch;
3. link related issues;
4. list exact validation commands and results;
5. describe public API, ABI, package, SDK, sysroot, target, deployment, and rollback impact; and
6. contain no generated output, secrets, private paths, credentials, or proprietary SDK files.

Use focused, imperative commit subjects. Reviewers may request changes when a patch narrows
portability, introduces an unsupported dependency, weakens a quality gate, or cannot be reproduced
through the documented command surface.

## Maintainer review

Review should consider more than whether the native build passes:

- Does the dependency direction remain library to application, not the reverse?
- Are error paths checked at the Linux and filesystem boundary?
- Do compile and link options leak into dependencies or consumers?
- Can the feature be configured for a real cross toolchain and sysroot?
- Are tests meaningful, deterministic, and correctly labeled?
- Do documentation, versioning, packaging, and release notes agree?
- Does the change alter remote devices or external systems without an explicit command?

Merge only after required checks complete and review findings are resolved.
