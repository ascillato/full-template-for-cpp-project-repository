# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial C++20 embedded Linux repository template.
- Native debug, release, analysis, coverage, and sanitizer presets.
- GNU/Linux AArch64 and Armv7 cross-build presets with optional sysroot support.
- Sample reusable library, command-line application, and automated tests.
- Formatting, static-analysis, spelling, coverage, documentation, packaging, and VS Code workflows.
- Sphinx, MyST, Breathe, and Doxygen documentation pipeline.
- Mermaid diagram rendering for Markdown on GitHub, in VS Code previews, and in the Sphinx site.
- Continuous integration, release, security, and community repository configuration.
- A single `.code-workspace` file containing all repository VS Code settings, extensions, tasks,
  status-bar buttons, inputs, and debug profiles; `.vscode/` remains ignored for user overrides.
- Make and VS Code entry points for staged and repository-wide pre-commit runs.

### Fixed

- `make check` now identifies the failed quality gate and its exit status while preserving the
  tool's diagnostics.
- Documentation CI dependency resolution by pairing Sphinx 9 with a compatible Read the Docs
  theme release.
- Inline-code contrast in the generated documentation when the operating system prefers dark
  colors.
- Formatter-version drift between native development, the development container, and CI by
  pinning clang-format 22.1.8.
- Clang 18 static analysis failures caused by CMake adding build-time C++ module map response files
  to the analysis compile database even though the project does not use C++ modules.
- Misleading clang-tidy warning totals in `make check`; the default output now shows actionable
  project diagnostics without statistics for suppressed system-header diagnostics.

[Unreleased]: https://github.com/ascillato/full-template-for-cpp-project-repository/commits/main
