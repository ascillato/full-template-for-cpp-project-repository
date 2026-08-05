# AI Agent Contribution Guidelines

These instructions apply to the entire repository. They are intended to help automated coding
agents make safe, reviewable changes to the C++ Embedded Linux Repository Template.

## Project contract

- The language baseline is C++20.
- The minimum supported CMake version is 3.25.
- Public C++ symbols use the `embedded_linux_template` namespace.
- The sample executable is `embedded-linux-template`.
- Generated content belongs below `build/`; do not commit or edit it.
- Native development uses the `dev` preset.
- Cross-builds use `arm64-release` and `armv7-release`.

## Start by inspecting

Before editing, read the files that define the affected interface and run `git status --short`.
Preserve unrelated changes, including uncommitted work. Search with `rg` or `rg --files` before
introducing a new pattern or dependency.

## Repository layout

- `include/embedded_linux_template/` contains installed public headers.
- `src/` contains reusable library implementations.
- `app/` contains command-line process startup.
- `tests/` contains unit and integration tests.
- `cmake/` and `CMakePresets.json` define build behavior and toolchains.
- `docs/` contains Sphinx/MyST guides and Doxygen configuration.
- `scripts/` contains non-trivial command orchestration used by Make and CI.
- `Embedded-Linux-Template.code-workspace` contains repository VS Code settings, tasks, launch
  configurations, and workspace behavior. Keep `.vscode/` untracked for user-local overrides.

Do not put reusable logic in `app/main.cpp`, test helpers in production targets, or machine-specific
SDK paths in shared presets.

## Supported commands

Use the repository entry points instead of inventing parallel command sequences:

- `make configure`, `make build`, `make run`, and `make test`
- `make check`, `make format-check`, `make tidy`, `make cppcheck`, `make spelling`, and
  `make shellcheck`
- `make format`, `make docs`, `make coverage`, `make sanitize`, and `make package`
- `make cross-arm64` and `make cross-armv7`
- `make clean`

`make deploy` changes an external target. Run it only when the user explicitly requests deployment
and provides or approves the exact device and destination.

## C++ and CMake changes

- Use target-scoped include paths, definitions, features, warnings, and link dependencies.
- Do not mutate global compiler or linker flags when a target property is sufficient.
- Preserve the C++20 compatibility baseline unless the task explicitly changes it.
- Keep public APIs documented; Doxygen warnings are build failures.
- Prefer deterministic, injectable behavior over hidden global state.
- Check Linux calls and error paths; do not assume a particular board, libc, or init system.
- Do not enable sanitizers, coverage flags, or host analysis tools for cross targets.
- Do not combine two unrelated CMake toolchain files.

## Verification

Verify in proportion to the change. The normal progression is:

```console
make format-check
make build
make test
make check
```

For documentation changes, run `make docs`. For target-sensitive C++ or CMake changes, run the
applicable `make cross-arm64` and `make cross-armv7` commands when the cross-compilers are
available. Report any skipped command and the missing prerequisite; never claim an unrun check
passed.

## Safety

- Never commit secrets, private keys, device credentials, or proprietary SDK contents.
- Keep destructive commands scoped to validated repository build directories.
- Do not deploy, publish a release, push commits, or modify a device unless the user requested it.
- Treat vendor SDK setup scripts as code: inspect them or require the user to activate them.
- Preserve license and attribution notices for imported code.

## Documentation and handoff

Update README or `docs/` when commands, presets, public behavior, supported targets, or developer
requirements change. Update `CHANGELOG.md` for user-visible changes. At handoff, summarize changed
files, verification performed, and any remaining target-specific assumptions.
