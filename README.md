# C++ Embedded Linux Repository Template

[![CI](https://github.com/ascillato/full-template-for-cpp-project-repository/actions/workflows/ci.yml/badge.svg)](https://github.com/ascillato/full-template-for-cpp-project-repository/actions/workflows/ci.yml)
[![CodeQL](https://github.com/ascillato/full-template-for-cpp-project-repository/actions/workflows/codeql.yml/badge.svg)](https://github.com/ascillato/full-template-for-cpp-project-repository/actions/workflows/codeql.yml)
[![Documentation](https://github.com/ascillato/full-template-for-cpp-project-repository/actions/workflows/docs.yml/badge.svg)](https://github.com/ascillato/full-template-for-cpp-project-repository/actions/workflows/docs.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

This is a complete template for C++ applications that run on embedded Linux. It contains a sample application and provides the build, test, analysis, documentation,
cross-compilation, packaging, deployment, and repository automation for a full project.

The workflow mirrors the one in
[`full-template-for-typescript-vscode-extension-repository`](https://github.com/ascillato/full-template-for-typescript-vscode-extension-repository):
VS Code status-bar buttons call a discoverable Make facade, and those same commands work in a
terminal and in CI.

## What is included

- C++20 library and sample Linux CLI with no runtime third-party dependencies.
- Modern target-based CMake, Ninja, install/export rules, presets, and CPack archives.
- Native Debug/Release, ASan+UBSan, coverage, analysis, ARM64, and ARMv7 presets.
- CTest and Catch2 3.15.3 unit tests plus process-level CLI integration tests.
- GCC and Clang warnings, clang-format, clang-tidy, cppcheck, codespell, and shellcheck.
- gcovr HTML, XML, and JSON coverage reports with a line-coverage quality gate.
- Doxygen API extraction and Sphinx/MyST/Breathe project documentation with Mermaid diagrams.
- Optional Conan 2 recipe and separate build/host profiles for cross dependencies.
- Ubuntu 26.04 development container with host, cross, QEMU, and GDB tooling.
- GitHub Actions for CI, CodeQL, dependency review, Pages, tagged releases, and maintenance.
- Community health files, issue forms, pre-commit hooks, and Dependabot configuration.
- Explicit SSH/rsync deployment and a VS Code `gdbserver` debugging profile.

## Quick start

### Recommended: development container

1. Install Docker and the VS Code **Dev Containers** extension.
2. Open `Embedded-Linux-Template.code-workspace` in VS Code.
3. Run **Dev Containers: Reopen in Container** from the Command Palette.
4. Run `make test`, or use the buttons that appear in the VS Code status bar.

The container supplies all host and cross-development tools. It is the easiest way to reproduce
CI locally.

### Native host

For the complete native environment on a Debian- or Ubuntu-based host, run the explicit setup
target. It installs host and cross compilers, analysis, documentation, debugging, metrics, QEMU,
and deployment tools through `apt`, then creates `.venv` with the pinned Python tools:

```bash
make setup-native
make test
make check
```

This command changes the host and may prompt for `sudo`. Preview every command without making
changes with `NATIVE_SETUP_DRY_RUN=1 make setup-native`. The installed CMake and Python versions
must satisfy the repository minimums of CMake 3.25 and Python 3.10. If GNU Make is not installed
yet, invoke `./scripts/setup-native.sh` directly; the script installs Make before bootstrapping the
Python environment.

The smaller build-only path requires CMake 3.25, Ninja, a C++20 compiler, Git, and Make:

```bash
sudo apt-get install build-essential cmake git ninja-build
make test
./build/dev/bin/embedded-linux-template --json
```

The first test configuration downloads Catch2 at the immutable commit recorded in
`cmake/Dependencies.cmake`. Set `EMBEDDED_LINUX_TEMPLATE_FETCH_DEPENDENCIES=OFF` when dependencies
must be supplied by Conan, a system package, or an offline SDK.

`make bootstrap` installs pinned CMake and clang-format releases used by native development, the
development container, and CI, so every environment evaluates the same build and formatting
rules.

## VS Code status-bar workflow

Open `Embedded-Linux-Template.code-workspace` and install the recommended extensions when VS Code
prompts. The `spencerwmiles.vscode-task-buttons` extension reads the workspace configuration and
adds these actions to the bottom status bar:

- Configure, build, run, test, quality checks, all-files pre-commit, and documentation.
- A **More Tools** menu for staged pre-commit, formatting, metrics, coverage, sanitizers,
  packaging, both cross builds, deployment, and granular cleaning.
- A new-terminal button.

The `.code-workspace` file is the repository's single source of truth for VS Code settings,
extensions, tasks, inputs, and debug profiles. Open it instead of the repository directory.
`Build (dev)` is the default build task, and `F5` starts the host GDB configuration after building.
The ignored `.vscode/` directory is reserved for each user's private folder-level overrides.

clangd supplies completion and diagnostics from `build/dev/compile_commands.json`. The Microsoft
C/C++ extension remains installed for GDB integration, but its duplicate IntelliSense engine is
disabled.

## Commands

Run `make help` for the authoritative list. The
[complete Make command reference](docs/make-commands.md) explains how every target works and why it
is useful in a C++ and embedded Linux workflow.

| Command | Result |
|---|---|
| `make configure` | Configure the `dev` preset, or `PRESET=<name>` |
| `make build` | Configure and compile the selected preset |
| `make run` | Build and run the native sample |
| `make test` | Build and run CTest with empty-suite detection |
| `make setup-native` | Install the complete Debian/Ubuntu native toolchain and Python environment |
| `make verify` | Check formatting, build, and test |
| `make check` | Run all-files pre-commit, clang-tidy, and cppcheck gates |
| `make pre-commit` | Run pre-commit hooks against staged files |
| `make pre-commit-all` | Run the same repository-wide pre-commit gate as CI |
| `make format` | Apply clang-format |
| `make sanitize` | Run the tests with AddressSanitizer and UBSan |
| `make coverage` | Write reports under `build/coverage` |
| `make docs` | Write the site under `build/docs/html` |
| `make metrics` | Generate source, complexity, coverage, and API reports under `build/metrics` |
| `make package` | Write a release `.tar.gz` under `build/release/packages` |
| `make cross-arm64` | Build and package with `aarch64-linux-gnu-*` |
| `make cross-armv7` | Build and package with `arm-linux-gnueabihf-*` |
| `make deploy TARGET_HOST=user@device` | Copy the ARM64 binary to an explicit target |
| `make install` | Stage the native install under `build/release/stage` |
| `make clean` | Remove repository-local generated build outputs |

Pass `JOBS=N` to cap build and test parallelism. The Makefile is intentionally thin: CMake presets
remain the source of truth and can always be invoked directly.

## CMake presets

| Preset | Purpose | Tests |
|---|---|---|
| `dev` | Native Debug development build | Yes |
| `release` | Optimized native build with IPO when supported | No |
| `analysis` | Small native compile database with warnings as errors | No |
| `coverage` | Native Debug build with gcov instrumentation | Yes |
| `sanitizers` | Native Debug build with ASan and UBSan | Yes |
| `docs` | Doxygen and Sphinx documentation build | No |
| `ci` | Strict native CI build | Yes |
| `arm64-release` | GNU AArch64 optimized build with local debug symbols | No |
| `armv7-release` | GNU ARM hard-float optimized build with local debug symbols | No |

For example:

```bash
cmake --workflow --preset dev-verify
cmake --preset release -DBUILD_SHARED_LIBS=ON
cmake --build --preset release
ctest --preset dev
```

Project warnings, sanitizer flags, coverage flags, and hardening are attached only to project
targets. They do not leak into Catch2 or downstream consumers, and warnings-as-errors is an opt-in
CI policy rather than a developer default.

## Embedded Linux cross-compilation

The working GNU examples are useful for Debian/Ubuntu-style targets and CI:

```bash
make setup-native
make cross-arm64
file build/arm64-release/bin/embedded-linux-template
```

Supply an SDK sysroot without editing the tracked preset:

```bash
EMBEDDED_SYSROOT=/opt/vendor-sdk/sysroots/target make cross-arm64
```

A generic template cannot guess a product's ABI, C library, kernel headers, or CPU flags. For a
production Yocto, Buildroot, or vendor SDK, copy `cmake/toolchains/custom-sdk.cmake.example` to an
untracked `custom-sdk.cmake`, then copy `CMakeUserPresets.json.example` to
`CMakeUserPresets.json` and adjust the local paths. Keep the SDK and sysroot outside Git.

The cross presets use `RelWithDebInfo`, retaining symbols in the local build tree for remote
debugging; CPack strips the portable release archives. The target OS builder should own final
`.deb`, `.rpm`, `.ipk`, image, and root-filesystem metadata.
The template's TGZ package is a portable staging artifact, not a substitute for a Yocto or
Buildroot recipe.

### Conan build and host profiles

Conan is optional; the ordinary build remains plain CMake. Use Conan when the application gains
third-party target dependencies:

```bash
conan profile detect --force
conan install . --build=missing \
  -s build_type=Debug -s compiler.cppstd=20 -o '&:build_tests=True'
conan create . --build=missing -s compiler.cppstd=20
conan install . \
  --profile:build=default \
  --profile:host=conan/profiles/linux-aarch64 \
  --build=missing
```

The separate build and host profiles ensure build tools execute on the workstation while libraries
are built for the device. When combining a vendor toolchain with Conan, configure it as Conan's
user toolchain; do not pass two unrelated `CMAKE_TOOLCHAIN_FILE` values.

## Deploy and remote debug

Deployment is never part of `all`, `build`, or `package`; it is an explicit remote side effect:

```bash
make cross-arm64
make deploy TARGET_HOST=user@device.local
```

Optional variables:

```bash
make deploy \
  TARGET_HOST=user@device.local \
  TARGET_DIR=/opt/my-product/bin \
  TARGET_SERVICE=my-product.service \
  BINARY=build/arm64-release/bin/embedded-linux-template
```

To debug, start the server on the target:

```bash
gdbserver :2345 /opt/embedded-linux-template/bin/embedded-linux-template
```

Then choose **Debug ARM64 (gdbserver)** in VS Code and provide the host and port. The launch profile
uses `gdb-multiarch` and the unstripped local cross binary. A QEMU smoke test is useful in CI, but it
does not replace testing on the real device.

## Documentation and coverage

Install the Python documentation packages, Doxygen, and Graphviz, then build:

```bash
make bootstrap
make coverage
make docs
```

- Documentation entry point: `build/docs/html/index.html`
- Doxygen XML: `build/docs/doxygen/xml`
- Detailed coverage: `build/coverage/html/index.html`
- Machine-readable coverage: `build/coverage/coverage.xml` and
  `build/coverage/coverage-summary.json`
- Code metrics: `build/metrics/summary.json` and the generated Code Metrics documentation page

The Pages workflow publishes the same Sphinx output from `main`. Documentation warnings fail the
build, and coverage fails below the configured line threshold. Markdown files can use standard
`mermaid` code fences; they render on GitHub, in current VS Code Markdown previews, and in the
generated documentation site.

The published site uses the full browser width and includes a persistent light/dark theme toggle.
Its Code Metrics page is refreshed during every documentation build; run `make coverage` first when
the page should include current test coverage.

## Current tool strategy

As of August 2026, upstream CMake is 4.4, Conan is 2.31, LLVM is 22.1, Catch2 is 3.15, gcovr is
8.6, Lizard is 1.23, Sphinx is 9.1, and Doxygen is 1.17. The dev environment and automation are
maintained against current tools, while the project baseline stays at CMake 3.25 and C++20 for
mature embedded SDK support. C++23 can be adopted by changing the single
`target_compile_features` declaration after confirming every shipping toolchain and standard
library.

Production cross-compilers and sysroots should come from the exact Yocto, Buildroot, or vendor SDK
used to build the target image. The generic GNU cross compilers in this template are examples and
CI portability checks.

## Repository layout

```text
app/                 Sample executable
include/             Installed public API
src/                 Library implementation
tests/               Catch2 unit and CTest integration tests
cmake/               Project modules, package config, and toolchain examples
conan/profiles/       Example Conan host profiles
scripts/              Quality, coverage, and deployment entry points
docs/                 Doxygen/Sphinx documentation sources
Embedded-Linux-Template.code-workspace
                      VS Code settings, tasks, buttons, extensions, and debug profiles
.devcontainer/        Consistent development environment
.github/              CI, security, release, Pages, and community automation
```

The sample reads hostname, kernel, architecture, and uptime information using Linux interfaces.
Replace it with product logic while retaining the surrounding targets and quality gates.

## CI and releases

Pull requests run formatting and analysis, GCC/Clang host tests, ASan+UBSan, coverage, both GNU ARM
cross builds, package/install checks, documentation, dependency review, and CodeQL. Workflows use
minimal permissions and concurrency cancellation.

Tags matching `vMAJOR.MINOR.PATCH` build release artifacts, create SHA-256 checksums, and publish a
GitHub release. `version.txt` is the single version source for CMake, generated C++ metadata,
packages, Conan, and documentation. Update it first and create a Git tag with exactly the same
value.
Before the first release, configure branch protection, GitHub Pages with **GitHub Actions** as its
source, Dependabot, private vulnerability reporting, and the repository's security settings.

## Using this template

After creating a repository from the template:

1. Rename the CMake project, targets, C++ namespace, include directory, and sample binary.
2. Set the initial release in `version.txt`, then update CPack metadata, documentation metadata,
   badges, URLs, and maintainer contact placeholders.
3. Replace the sample library/application and tests without removing the CI contract.
4. Replace the GNU example toolchain with the product SDK and record its version/checksum.
5. Set supported architectures, minimum compiler versions, coverage threshold, and security policy.
6. Review deployment paths and service names before enabling deployment for a real target.
7. Mark the GitHub repository as a template and enable Pages, Actions, CodeQL, and branch rules.

## Contributing and security

Read [CONTRIBUTING.md](CONTRIBUTING.md) for the development contract and
[SUPPORT.md](SUPPORT.md) for support boundaries. Report vulnerabilities privately as described in
[SECURITY.md](SECURITY.md); do not open public issues for undisclosed security problems.

This project is available under the [MIT License](LICENSE).
