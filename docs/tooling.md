# Tooling

The repository deliberately separates tools required for the core build from tools used for
quality, reports, documentation, and cross-compilation.

## Tool inventory

| Tool | Purpose | Entry point |
| --- | --- | --- |
| CMake 3.25+ | Configure targets, install rules, and packages | `cmake --preset dev` |
| Ninja | Fast preset builds | `make build` |
| GCC or Clang | Native C++20 compilation | `make build` |
| Catch2 and CTest | Unit discovery and test execution | `make test` |
| clang-format | Source formatting | `make format` |
| pre-commit | Reproduce repository-wide file gates | `make pre-commit-all` |
| clang-tidy | Compiler-aware static analysis | `make tidy` |
| cppcheck | Complementary portability and defect checks | `make cppcheck` |
| codespell | Documentation and source spelling | `make spelling` |
| gcovr | Native coverage capture, reports, and threshold | `make coverage` |
| Doxygen | C++ API extraction to XML | `make docs` |
| Sphinx, MyST, Breathe, Mermaid | Guide, diagram, and API site rendering | `make docs` |
| GNU cross-compilers | AArch64 and Armv7 builds | `make cross-arm64` / `make cross-armv7` |
| GDB multiarch | Native and remote target debugging | VS Code launch configurations |
| QEMU user-mode | Cross-binary smoke tests in CI | `.github/workflows/ci.yml` |
| CPack | Release archives | `make package` |
| shellcheck | Shell-script validation | `make shellcheck` |
| cloc | Source-line metrics | `make metrics` |
| SSH and rsync | Explicit target deployment | `make deploy` |

## Checks and optional tools

On Debian and Ubuntu, `make setup-native` installs the complete tool inventory needed by the
repository's native workflows, including both GNU Arm cross-compilers, and then creates `.venv`
with the pinned CMake and Python tools. It is explicit because it installs host packages with
`apt` and may prompt for `sudo`. Use `NATIVE_SETUP_DRY_RUN=1 make setup-native` to review the
commands first. On a minimal host without GNU Make, invoke `./scripts/setup-native.sh` directly.
Other distributions should install equivalent packages manually or use the development container.

`make check` runs the all-files pre-commit gate followed by clang-tidy and cppcheck, matching the
quality job in CI. The pre-commit gate includes formatting, spelling, and shell-script checks. Run
`make pre-commit` for staged files or `make pre-commit-all` for the whole repository. Run
`make format-check`, `make tidy`, `make cppcheck`, `make spelling`, or `make shellcheck` to isolate
one check. Missing tools must produce an actionable diagnostic and must never be silently treated
as a successful CI check.

`make tidy` configures the `analysis` preset before analyzing its compile database. `make sanitize`
configures, builds, and tests the `sanitizers` preset.

Clang-tidy reports every diagnostic from repository sources and public headers. Its default output
omits statistics for diagnostics suppressed in toolchain and system headers, which are not
actionable in this repository. To inspect those third-party diagnostics explicitly, run
`TIDY_SYSTEM_HEADERS=1 make tidy`; this can produce a very large report and may fail because all
enabled clang-tidy warnings are treated as errors.

Apply automated fixes separately:

```console
make format
```

Static analysis consumes the compile database produced by the `analysis` preset. Analyzer
diagnostics are meaningful only when compiler options, generated headers, target definitions, and
include paths match the build being examined.

## Documentation pipeline

`make docs` performs these steps in order:

1. CMake configures `docs/Doxyfile.in` with source, binary, and project-version paths.
2. Doxygen validates public API comments and writes XML below `build/docs/doxygen/xml`.
3. Sphinx reads the Markdown guides, renders Mermaid diagrams, and Breathe reads the Doxygen XML.
4. Sphinx writes the site to `build/docs/html`.

Doxygen warnings are errors. Sphinx should likewise run with warnings promoted to errors in CI.

The documentation version is read directly from the repository-root `version.txt`. For a direct
Sphinx invocation, override the generated XML location when necessary:

```console
DOXYGEN_XML_DIR=../build/docs/doxygen/xml \
sphinx-build -W --keep-going -b html docs build/docs/html
```

Relative `DOXYGEN_XML_DIR` values are resolved from the `docs` directory.

### Project version

`version.txt` is the single project-version source and must contain one `vMAJOR.MINOR.PATCH` value.
CMake removes the leading `v` for its numeric `project(VERSION ...)` value, generated C++ version
header, install metadata, and CPack archive names. Conan uses the same numeric value. Sphinx keeps
the tag form and displays it below the project title in the documentation sidebar.

To prepare a release, update `version.txt`, rebuild and test the package and documentation, then
create a Git tag whose name exactly matches the file. Do not edit generated version headers or
hard-code the version in CMake, Conan, or Sphinx.

### Mermaid diagrams

Use standard GitHub-compatible Mermaid code fences in Markdown files:

````markdown
```mermaid
flowchart LR
    source["Source"] --> build["Build"] --> target["Embedded target"]
```
````

The same fence syntax renders in GitHub, in the built Sphinx site, and in the Markdown preview of
VS Code 1.121 or newer. The workspace does not recommend a separate Mermaid extension because that
support is built in. Keep diagrams readable in both light and dark themes, use descriptive node
labels, and avoid diagram links to untrusted destinations.

## Visual Studio Code

The workspace recommends CMake Tools, clangd, C++ debugging support, Catch2 test integration,
spelling, and the task-buttons extension. Status-bar buttons dispatch the same Make targets shown
in this documentation.

clangd owns code intelligence. C/C++ debugging support remains enabled for GDB, while its separate
IntelliSense engine is disabled to avoid duplicate diagnostics and indexes. clangd reads
`build/dev/compile_commands.json`.

## Preset and cache hygiene

- Shared configurations belong in `CMakePresets.json`.
- Machine-local SDK paths belong in ignored `CMakeUserPresets.json`.
- Never edit `CMakeCache.txt` to preserve a configuration.
- Reconfigure from a fresh build directory after changing compilers, sysroots, ABI options, or
  toolchain files.
- Keep generated reports and dependency caches outside the source directories.

## Packaging

`make package` builds from the `release` preset and uses CPack. A package must contain only declared
install artifacts. Validate the archive on a clean machine or staging root before treating it as a
release candidate.
