# Support

## Start with the documentation

- [README](README.md) for setup and common commands
- [Development guide](docs/development.md) for native work
- [Cross-compiling guide](docs/cross-compiling.md) for toolchains and sysroots
- [Testing guide](docs/testing.md) for CTest, sanitizers, and coverage
- [Tooling guide](docs/tooling.md) for required and optional tools

Run `make help` to see the command interface implemented by the current revision.

## Ask a question

Use [GitHub Discussions](https://github.com/ascillato/full-template-for-cpp-project-repository/discussions)
for setup questions, design discussion, and help adapting the template. Search existing discussions
and issues first.

When asking for help, include:

- the repository revision or release;
- host operating system and architecture;
- compiler and CMake versions;
- preset and exact command used;
- target architecture, SDK, libc, and `EMBEDDED_SYSROOT` arrangement when cross-compiling; and
- the smallest complete diagnostic output, formatted as text rather than a screenshot.

Remove credentials, private hostnames, proprietary paths, and vendor SDK contents before posting.

## Bugs and feature requests

Use the repository's issue forms for reproducible template defects and scoped enhancements. An
issue tracker is not a support channel for an unsupported vendor SDK or a private project derived
from the template, but maintainers may help identify whether the problem is generic.

## Security and conduct

Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md). Do not include
security-sensitive details in a public support request.

Report unacceptable community behavior through the private channel described in
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
