# Make command reference

The Makefile is the repository's human-facing command surface. It keeps terminal, Visual Studio
Code, and CI invocations consistent while CMake targets and presets remain the source of truth for
compilation. Run `make help` (or simply `make`) to print the current target list.

Commands use the following optional variables:

- `PRESET=<name>` selects a CMake configure, build, and test preset where the target supports it;
  the default is `dev`.
- `JOBS=<number>` caps CMake and CTest parallel work. With no value, those tools choose their own
  concurrency.
- deployment-specific variables are described with {ref}`make-deploy`.

## Setup and discovery

### `make help`

**How it works:** Parses the documented targets in the Makefile and prints their short summaries,
along with the supported `PRESET` and `JOBS` arguments. It is also the default goal, so bare `make`
shows help.

**Why it is useful:** A discoverable build interface reduces the need to memorize CMake, CTest,
CPack, analyzer, and documentation command lines.

### `make bootstrap`

**How it works:** Creates or refreshes `.venv`, upgrades `pip`, and installs the pinned development
and documentation Python requirements. When `.venv` exists, the Makefile places its executables at
the front of `PATH` for subsequent targets.

**Why it is useful:** Pinning tools such as CMake, clang-format, pre-commit, gcovr, Conan, and
Sphinx prevents tool-version drift between developers and CI without changing system packages.

### `make setup-native`

**How it works:** On Debian or Ubuntu, installs the complete host and GNU Arm toolchain through
`apt`, then runs `make bootstrap`. It may use `sudo`; set `NATIVE_SETUP_DRY_RUN=1` to print the
commands without changing the host.

**Why it is useful:** It provides an explicit alternative to the development container when native
compilers, analyzers, documentation tools, cross-compilers, QEMU, and deployment utilities are all
needed locally.

## Native build and test loop

### `make all`

**How it works:** Delegates to `make build` with the selected preset. It is an explicit target, not
the default goal.

**Why it is useful:** It provides the conventional Make name for producing the primary native
artifact while preserving the preset-based build.

### `make configure`

**How it works:** Runs `cmake --preset "$PRESET"`; `PRESET=dev` is used by default. CMake validates
the toolchain and options and generates Ninja files below `build/<preset>/`.

**Why it is useful:** Configuration catches missing dependencies and incompatible build options
before compilation and makes every supported C++ build mode reproducible.

### `make build`

**How it works:** Configures the selected preset, then runs its CMake build preset. For example,
`make build PRESET=release JOBS=4` creates an optimized native build with at most four parallel
jobs.

**Why it is useful:** Incremental Ninja builds are fast, while mandatory configuration ensures
changes to CMake files, options, and the project version are reflected in generated artifacts.

### `make run`

**How it works:** Builds the selected native preset and launches
`build/<preset>/bin/embedded-linux-template`.

**Why it is useful:** It shortens the edit-build-run loop for the sample application. Use a native
preset; a cross-compiled Arm executable normally cannot run directly on the development host.

### `make test`

**How it works:** Builds the selected preset and invokes its CTest preset in parallel. Supported
test presets are `dev`, `coverage`, `sanitizers`, and `ci`; failed tests print their output and an
empty test suite is an error.

**Why it is useful:** CTest executes both Catch2 unit tests and process-level CLI tests through one
interface and makes the same test graph available locally and in CI.

### `make verify`

**How it works:** Runs `format-check`, then the selected native build and tests. Make stops at the
first failing prerequisite.

**Why it is useful:** This is the fast pre-push path: it catches formatting drift, compiler
failures, and behavioral regressions without running every static analyzer.

## Formatting and quality gates

### `make format-check`

**How it works:** Runs the pinned clang-format in dry-run, error-on-difference mode across C and C++
sources, headers, tests, and the consumer example. It never modifies files.

**Why it is useful:** Deterministic formatting avoids review noise and ensures CI evaluates the
same source layout as local development.

### `make format`

**How it works:** Runs clang-format in place over the same repository-owned C and C++ files used by
`format-check`.

**Why it is useful:** Automated formatting is safer and faster than manually resolving style
differences, especially for nested templates and modern C++ expressions.

### `make spelling`

**How it works:** Runs codespell with the repository configuration over source, documentation, and
configuration files.

**Why it is useful:** Correct names and documentation improve API searchability and prevent typos
from becoming long-lived public identifiers.

### `make tidy`

**How it works:** Configures the Clang-based `analysis` preset, then runs clang-tidy against its
compile database for application and library sources. Project diagnostics fail the command. Set
`TIDY_SYSTEM_HEADERS=1` only when intentionally auditing the much larger toolchain-header output.

**Why it is useful:** clang-tidy understands the real compiler flags, macros, generated headers,
and include paths, so it can find C++ correctness, lifetime, modernization, and maintainability
issues that text-only checks cannot.

### `make cppcheck`

**How it works:** Runs cppcheck with warning, style, performance, and portability checks against
`app/` and `src/`, using C++20 mode and the public include directory.

**Why it is useful:** An analyzer with a different implementation catches defect patterns and
portability risks that may not be reported by the compiler or clang-tidy.

### `make shellcheck`

**How it works:** Runs ShellCheck over every repository script in `scripts/`.

**Why it is useful:** Build and deployment scripts are production code too; quoting, expansion,
and error-handling defects can invalidate a C++ build or affect a target device.

### `make pre-commit`

**How it works:** Runs configured pre-commit hooks against the files staged in Git and displays a
diff when a hook changes or rejects a file.

**Why it is useful:** It gives quick feedback on exactly the files about to be committed, including
formatting, spelling, YAML/JSON validity, line endings, merge markers, and shell checks.

### `make pre-commit-all`

**How it works:** Runs the same hooks as `make pre-commit`, but against every tracked repository
file rather than only the staged set.

**Why it is useful:** This reproduces the repository-wide pre-commit gate used by CI and detects
problems in files affected indirectly by a tool or configuration change.

### `make check`

**How it works:** Runs `pre-commit-all`, `tidy`, and `cppcheck` in order, labels each phase, and
stops with the failing tool's exit status. Formatting, spelling, and ShellCheck are included through
the pre-commit configuration.

**Why it is useful:** The aggregate gate combines file hygiene with two independent C++ static
analyzers and clearly identifies which layer failed.

### `make check-strict`

**How it works:** Currently aliases `make check`. The distinct name is reserved for environments
where all quality tools are mandatory; missing tools already cause a failure.

**Why it is useful:** Automation can express a strict quality policy through a stable target name
even if the individual checks evolve later.

## Runtime diagnostics and reports

### `make sanitize`

**How it works:** Configures, builds, and tests the native `sanitizers` preset with AddressSanitizer
and UndefinedBehaviorSanitizer enabled and frame pointers retained.

**Why it is useful:** Sanitizers detect memory safety defects and undefined behavior at runtime,
including issues that compile cleanly and may otherwise fail only on a device.

### `make coverage`

**How it works:** Builds the GCC-instrumented `coverage` preset, removes stale counter data, runs
the tests, and uses gcovr to create HTML, XML, and JSON reports below `build/coverage/`. It fails
when line coverage is below 85 percent.

**Why it is useful:** Coverage reveals unexercised branches and error paths and supplies both a
human report and machine-readable CI artifacts. The threshold is a guardrail, not a substitute for
meaningful assertions.

### `make docs`

**How it works:** Configures the `docs` preset, runs Doxygen with warnings treated as errors, then
generates the code-metrics data and uses Sphinx, MyST, Breathe, and Mermaid to write the HTML site
to `build/docs/html`. The displayed version is read from `version.txt`.

**Why it is useful:** Building API comments and narrative guides together catches stale references,
invalid diagrams, and undocumented public C++ interfaces before publication.

### `make metrics`

**How it works:** Generates Markdown and JSON reports below `build/metrics`. cloc measures lines by
language and file, Lizard measures C++ function complexity, and the generator incorporates gcovr
coverage and Doxygen API data when those reports already exist.

**Why it is useful:** Size, complexity, test coverage, and public-API trends identify review and
refactoring hotspots from complementary perspectives. They are engineering signals, not developer
productivity scores.

## Packaging and downstream validation

### `make package`

**How it works:** Configures and builds the optimized native `release` preset, then asks CPack to
create a portable `.tar.gz` below `build/release/packages/`. Package names use the numeric form of
the version in `version.txt`.

**Why it is useful:** Packaging the declared install rules exposes missing runtime files and
provides a reproducible artifact for release testing.

### `make install`

**How it works:** Builds the native `release` preset and stages its install rules below
`build/release/stage` rather than modifying the host system.

**Why it is useful:** A staged tree lets maintainers inspect the exact headers, library, executable,
licenses, and CMake package metadata that downstream users receive.

### `make consumer-test`

**How it works:** Creates the staged release, configures the independent project in `test_package/`
with that stage as `CMAKE_PREFIX_PATH`, builds it, and runs its executable.

**Why it is useful:** A project can build internally while exporting a broken CMake package. This
test proves that an external consumer can call `find_package` and link the installed target.

## Cross-compilation and deployment

### `make cross-arm64`

**How it works:** Configures and builds the `arm64-release` preset with the GNU
`aarch64-linux-gnu-*` toolchain, then creates an AArch64 package with CPack.

**Why it is useful:** Compiling with the target ABI catches host-only assumptions, incompatible
flags, and missing target dependencies before code reaches a 64-bit Arm device.

### `make cross-armv7`

**How it works:** Configures and builds the `armv7-release` preset with the GNU
`arm-linux-gnueabihf-*` hard-float toolchain, then creates an Armv7 package with CPack.

**Why it is useful:** A separate 32-bit build catches pointer-width, architecture, and older ABI
assumptions that an AArch64 build cannot reveal.

(make-deploy)=
### `make deploy`

**How it works:** Validates the explicit target settings, creates the remote destination over SSH,
and copies the executable with rsync. `TARGET_HOST=user@device` is required. `TARGET_DIR` defaults
to `/opt/embedded-linux-template/bin`, `BINARY` defaults to the Arm64 release executable, and
optional `TARGET_SERVICE` restarts a validated systemd unit after copying.

**Why it is useful:** Deployment is intentionally separate from builds because it changes an
external system. The helper provides a reviewable baseline while keeping device identity,
credentials, paths, and service policy explicit.

### `make conan-install`

**How it works:** Uses Conan's build/host model to resolve optional dependencies into `build/conan`,
building missing packages and enabling this project's tests for a Debug C++20 configuration.

**Why it is useful:** Conan becomes valuable when an embedded application gains third-party target
libraries, especially when build-machine tools and device libraries require different profiles.
The ordinary template build remains plain CMake.

## Cleaning generated output

### `make tests-clean`

**How it works:** Removes coverage output and the native `dev` preset's CTest result directory.

**Why it is useful:** It resets test counters and results without discarding every configured and
compiled build tree.

### `make docs-clean`

**How it works:** Removes the generated `build/docs` and `build/metrics` trees, including Doxygen
XML, Sphinx HTML, and documentation metrics.

**Why it is useful:** A clean documentation rebuild distinguishes source problems from stale API
or Sphinx output.

### `make package-clean`

**How it works:** Removes package archives for the native release, AArch64, and Armv7 presets while
leaving their compiled build trees in place.

**Why it is useful:** It permits quick package regeneration and avoids accidentally distributing
an older archive.

### `make clean`

**How it works:** Uses CMake's portable file operations to remove the repository-local `build/`
tree and root compile-command link. It does not remove source files, `.venv`, or host-installed
tools.

**Why it is useful:** A full out-of-source reset is the reliable recovery path after changing
compilers, sysroots, ABI settings, or incompatible cached CMake options.
