## Summary

Describe the change and why it is needed. Keep the scope focused and link related issues with
`Closes #123` or `Fixes #123` where appropriate.

## Type of change

- [ ] Bug fix
- [ ] Feature or enhancement
- [ ] Breaking or compatibility change
- [ ] Refactoring or maintenance
- [ ] Documentation
- [ ] Build, tooling, CI, or release infrastructure

## Validation

List the exact commands, presets, host toolchains, emulators, and target devices used. Do not mark a
check as complete if it was skipped.

- [ ] `make format-check`
- [ ] `make check`
- [ ] `make build`
- [ ] `make test`
- [ ] `make docs` when documentation or public APIs changed
- [ ] `make sanitize` when runtime behavior changed
- [ ] `make cross-arm64` when target-sensitive code or build logic changed
- [ ] `make cross-armv7` when target-sensitive code or build logic changed
- [ ] Target-hardware validation, when applicable

Commands and results:

```text
Paste a concise summary here.
```

## Compatibility and deployment impact

Describe effects on C++20/CMake 3.25 compatibility, public API or ABI, package contents, sysroots,
vendor SDKs, target architectures, configuration, deployment, and rollback. Write "None" where
appropriate.

## Documentation and release notes

- [ ] Public behavior and APIs are documented.
- [ ] `CHANGELOG.md` is updated for a user-visible change.
- [ ] No generated output, credentials, private paths, or proprietary SDK files are included.

## Reviewer notes

Call out risky areas, deliberate trade-offs, follow-up work, or code that deserves extra attention.
