# Support

The repository-root
[`SUPPORT.md`](https://github.com/ascillato/full-template-for-cpp-project-repository/blob/main/SUPPORT.md)
defines the authoritative support boundaries. The template community can help with the generic
build, test, documentation, cross-compilation, and packaging infrastructure; a project created from
the template remains responsible for its own product and vendor integration.

## Find the relevant guide

- Start with {doc}`overview` to understand the template's purpose and limits.
- Use {doc}`development` for the development container and native setup.
- Use {doc}`make-commands` for the complete command interface.
- Use {doc}`cross-compiling` for compilers, SDKs, sysroots, QEMU, and target debugging.
- Use {doc}`testing` for CTest, sanitizers, and coverage.
- Use {doc}`tooling` and {doc}`documentation` for analysis and site-generation prerequisites.
- Use {doc}`continuous-integration` to reproduce GitHub Actions failures.

Run `make help` against the revision in question because commands can evolve between releases.

## Ask for help

Use [GitHub Discussions](https://github.com/ascillato/full-template-for-cpp-project-repository/discussions)
for setup questions, design discussion, and help adapting the template. Search existing discussions
and issues first.

Include enough context to make the result reproducible:

- release tag or commit identifier;
- host operating system and architecture;
- exact compiler, CMake, and relevant tool versions;
- preset and complete command used;
- complete diagnostic output as text;
- whether the development container or a native host was used; and
- for cross-builds, the architecture, compiler, SDK, libc, sysroot arrangement, and target board.

Prefer the smallest example that still fails. Remove passwords, tokens, private keys, private
hostnames, production addresses, customer data, proprietary paths, and vendor SDK contents before
posting.

## Bugs and feature requests

Use the repository issue forms for a reproducible defect in the generic template or for a scoped
enhancement useful to multiple embedded Linux projects. Include expected and actual behavior,
clean-build reproduction steps, and relevant compatibility constraints.

An issue tracker cannot provide product support for a private derived repository or guarantee
compatibility with an unsupported vendor SDK. Maintainers may still help identify whether the
failure belongs to the generic CMake boundary or to the product toolchain.

## Private reports and community conduct

Never report an undisclosed vulnerability in a public discussion, issue, log, or screenshot. Use
the private route in {doc}`security`. Report unacceptable community behavior through the private
channel in {doc}`code-of-conduct`.
