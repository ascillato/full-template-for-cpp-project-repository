# Development workflow

## Choose an environment

### Development container

Open the repository in Visual Studio Code and choose **Dev Containers: Reopen in Container**. Install
the recommended workspace extensions when prompted. This gives contributors a consistent native,
cross, analysis, test, documentation, and debugging environment.

### Native Linux host

On Debian or Ubuntu, install the complete native development environment with:

```console
make setup-native
```

The target uses `apt` with root privileges or `sudo`, then runs `make bootstrap` for the pinned
Python environment. Preview its commands without changing the host with
`NATIVE_SETUP_DRY_RUN=1 make setup-native`. On a minimal host without GNU Make, run
`./scripts/setup-native.sh` directly instead.

For a manual or non-Debian setup, install at minimum:

- a compiler with C++20 support;
- CMake 3.25 or newer;
- Ninja;
- GNU Make and Git; and
- Python 3 with virtual-environment support for documentation.

Quality, coverage, documentation, and cross-build commands need the additional tools described in
{doc}`tooling`.

## Build and run

The default development loop uses the `dev` preset:

```console
make configure
make build
make run
```

The equivalent direct CMake commands are:

```console
cmake --preset dev
cmake --build --preset dev
```

Build an optimized native binary with:

```console
cmake --preset release
cmake --build --preset release
```

To use a different supported preset through Make, set `PRESET`, for example:

```console
make build PRESET=release
```

## Before opening a pull request

Run:

```console
make format
make format-check
make check
make test
make docs
```

The aggregate `check` target runs the same all-files pre-commit gate as CI, followed by clang-tidy
and cppcheck. Use `make pre-commit` for staged files, `make pre-commit-all` for all repository
files, or the `format-check`, `tidy`, `cppcheck`, `spelling`, and `shellcheck` targets when iterating
on one class of diagnostic.

If a change can affect target compilation, also run the relevant cross-build:

```console
make cross-arm64
make cross-armv7
```

## Coding rules

- Keep the C++20 baseline unless an intentional compatibility decision changes it.
- Put public declarations below `include/embedded_linux_template/`.
- Keep implementation details in `src/` and process startup in `app/`.
- Prefer deterministic, testable functions over hidden global state.
- Treat compiler warnings as defects; CI may elevate them to errors.
- Apply `.clang-format` rather than hand-formatting around it.
- Document every public API sufficiently for strict Doxygen validation.
- Use standard-library facilities where they meet target requirements.
- Check allocation, exception, threading, and C-library assumptions against the target SDK before
  adding them to low-level code.

## Generated files

Do not edit generated version headers, Doxygen XML, Sphinx HTML, coverage output, CMake caches,
compile databases, or package staging directories. Change their source configuration and rebuild.

The repository-root `version.txt` is the only source for the project version. It uses the release
tag form `vMAJOR.MINOR.PATCH`; CMake and Conan remove the leading `v` where a numeric version is
required. Change this file before a release and use the exact same value for the Git tag.

`make clean` removes only validated repository build outputs. Never use a broad recursive deletion
to imitate it.

## Adding a source file

1. Place public headers or private sources in the appropriate layer.
2. Add the file to the owning CMake target.
3. Link dependencies to that target with the narrowest useful visibility.
4. Add or update tests.
5. Update API and guide documentation when behavior or public interfaces change.
6. Run the native verification and applicable cross-builds.
