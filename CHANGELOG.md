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

### Fixed

- Inline-code contrast in the generated documentation when the operating system prefers dark
  colors.

[Unreleased]: https://github.com/ascillato/full-template-for-cpp-project-repository/commits/main
