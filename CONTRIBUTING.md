# Contributing

Thank you for improving the C++ Embedded Linux Repository Template. Contributions should remain
portable, testable, documented, and useful to projects with different boards and SDKs.

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Before starting

- Search existing issues and pull requests for related work.
- Open a feature request before a large architectural or compatibility change.
- Report vulnerabilities privately according to [SECURITY.md](SECURITY.md).
- Keep board-specific behavior out of the generic template unless it is an optional example.

## Development environment

The recommended environment is the checked-in development container. In Visual Studio Code, open
the repository and choose **Dev Containers: Reopen in Container**.

For native Linux development, install a C++20 compiler, CMake 3.25 or newer, Ninja, GNU Make, and
Git. Additional analysis, documentation, coverage, and cross tools are listed in
[the tooling guide](docs/tooling.md).

## Build and test

```console
make configure
make build
make test
```

Run the sample with `make run`. Direct CMake users can use:

```console
cmake --preset dev
cmake --build --preset dev
ctest --preset dev --output-on-failure
```

## Quality checks

Before submitting a pull request, run:

```console
make format
make format-check
make check
make test
make docs
```

The individual quality targets are `tidy`, `cppcheck`, `spelling`, and `shellcheck`. Use
`make sanitize` for changes involving memory ownership, buffer boundaries, casts, or undefined
behavior. Use `make coverage` when evaluating whether new behavior has meaningful tests.

Changes that can affect cross-compilation should also run:

```console
make cross-arm64
make cross-armv7
```

If a toolchain is unavailable, state that clearly in the pull request rather than claiming the
check passed.

## Coding standards

- Preserve the C++20 baseline.
- Put public declarations below `include/embedded_linux_template/` and implementations in `src/`.
- Keep `app/main.cpp` focused on argument handling and process lifetime.
- Use the existing `.clang-format` and `.clang-tidy` configurations.
- Apply compiler options and dependencies to individual CMake targets.
- Avoid assumptions about CPU, byte order, libc, filesystem layout, systemd, or hardware access.
- Handle Linux system-call failures and make deterministic behavior independently testable.
- Document public APIs with Doxygen comments, including parameters, return values, and errors.
- Do not edit generated output below `build/`.

## Tests

Add unit tests for reusable behavior and CLI integration tests for stable command contracts. Tests
must not depend on the developer hostname, kernel release, locale, wall clock, network, or hardware
unless they are explicitly marked as target tests.

Every defect fix should include a regression test when practical. Test-only dependencies must not
be exported to consumers of the installed package.

## Documentation

Update `README.md` or `docs/` when commands, presets, behavior, public APIs, requirements, or target
assumptions change. Build the site with `make docs`; warnings from Doxygen or Sphinx must be fixed.

Add user-visible changes to the `Unreleased` section of [CHANGELOG.md](CHANGELOG.md).

## Commits and pull requests

- Keep commits focused and write imperative commit subjects.
- Explain why the change is needed, not only what changed.
- Link related issues.
- Complete the pull request checklist and record the exact tests and target environments used.
- Avoid unrelated reformatting or generated files.
- Preserve existing user changes in a dirty worktree.

Maintainers may ask for changes when a contribution narrows portability, introduces an unsupported
dependency, or cannot be reproduced through the documented workflow.
