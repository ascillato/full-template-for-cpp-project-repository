# C++ Embedded Linux Repository Template

This repository is a complete starting point for C++20 applications that run on
embedded Linux. It keeps the sample deliberately small while providing repeatable native and
cross builds, automated tests, code-quality checks, API documentation, packaging, and a Visual
Studio Code workflow.

The generated site combines these project guides with API information extracted by Doxygen and
rendered through Breathe.

```{toctree}
:maxdepth: 2
:caption: User guide

overview
usage
architecture
cross-compiling
```

```{toctree}
:maxdepth: 2
:caption: Developer guide

development
make-commands
testing
tooling
documentation
code-metrics
continuous-integration
api
release-management
```

```{toctree}
:maxdepth: 1
:caption: Project

contributing
changelog
security
support
code-of-conduct
license
```

## Quick start

The recommended route is to open the repository in its development container. The container
provides the native compiler, cross-compilers, CMake, Ninja, analysis tools, documentation tools,
GDB, and QEMU.

For a native setup, install a C++20 compiler, CMake 3.25 or newer, Ninja, Git, and Python 3. Then
run:

```console
make configure
make build
make test
```

Build and run the sample explicitly with:

```console
make build
make run
```

The native development preset is `dev`. Generated files stay under `build/`; source and generated
artifacts are intentionally kept separate.

## Common workflows

| Goal | Command |
| --- | --- |
| Configure and build a debug binary | `make build` |
| Run all native tests | `make test` |
| Run the aggregate quality checks | `make check` |
| Run pre-commit against staged files | `make pre-commit` |
| Run the same all-files pre-commit gate as CI | `make pre-commit-all` |
| Check formatting without changing files | `make format-check` |
| Run clang-tidy analysis | `make tidy` |
| Run cppcheck analysis | `make cppcheck` |
| Check documentation and source spelling | `make spelling` |
| Apply source formatting | `make format` |
| Build this documentation | `make docs` |
| Generate source, complexity, coverage, and API metrics | `make metrics` |
| Generate an instrumented coverage report | `make coverage` |
| Build and test with sanitizers | `make sanitize` |
| Build for 64-bit Arm Linux | `make cross-arm64` |
| Build for 32-bit Arm Linux | `make cross-armv7` |
| Build a release package | `make package` |
| Deploy with explicit target settings | `make deploy` |

Use `make help` for the authoritative target list.
See {doc}`make-commands` for how every target works and why it belongs in a C++ workflow.

## Template boundaries

The sample reads ordinary Linux system information; it does not assume a board, BSP, init system,
GPIO library, deployment account, or filesystem layout. Integrate hardware access and deployment
only after selecting the target platform and vendor SDK.

```{note}
Cross-compilation proves that the code and linker inputs are suitable for an architecture. It does
not replace tests on the actual hardware, kernel, C library, and root filesystem used in production.
```
