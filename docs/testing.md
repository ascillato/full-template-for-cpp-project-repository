# Testing

The test layout distinguishes reusable-library behavior from executable behavior.

## Test levels

Unit tests
: Exercise deterministic library behavior using Catch2. System-information formatting should use
  fixture values rather than depending on the build host.

Integration tests
: Launch `embedded-linux-template` through CTest and validate stable command-line contracts such as
  `--help`, `--version`, exit status, and key output fields.

Target tests
: Run the packaged application and relevant hardware integrations on representative devices. These
  remain project-specific and are not simulated by the generic template.

## Run native tests

```console
make test
```

For more detail:

```console
ctest --preset dev --output-on-failure
```

Filter by test name while iterating:

```console
ctest --preset dev --show-only
ctest --preset dev -L unit --output-on-failure
```

Do not encode assumptions about the developer hostname, kernel release, filesystem, locale, or
working directory into unit assertions.

## Sanitizers

Build and test the dedicated native preset with the Make target:

```console
make sanitize
```

The equivalent direct commands are:

```console
cmake --preset sanitizers
cmake --build --preset sanitizers
ctest --preset sanitizers --output-on-failure
```

AddressSanitizer and UndefinedBehaviorSanitizer detect important classes of defects, but support
depends on the host compiler and runtime. Sanitizer flags are intentionally excluded from ordinary
cross builds.

## Coverage

```console
make coverage
```

The coverage preset configures an instrumented native build, executes tests, and generates HTML,
Cobertura XML, and JSON summary reports below `build/coverage/`. The current coverage gate requires
at least 85 percent line coverage. Coverage is a diagnostic for untested paths, not a measure of
correctness. Prefer meaningful boundary, failure, and state-transition cases over a numerical
target alone.

## Cross-build validation

Cross compilation belongs in CI even when cross binaries cannot execute there. It catches target
compiler differences, unsupported flags, architecture assumptions, and missing sysroot
dependencies.

Where QEMU is available, a smoke test may run the cross-built CLI. Mark it separately from native
unit tests and retain device testing for release qualification.

## Writing maintainable tests

- Give tests behavior-oriented names.
- Keep one reason for failure per assertion section.
- Inject or wrap operating-system observations when deterministic values matter.
- Test public behavior instead of private implementation details.
- Add a regression test before or with every defect fix.
- Avoid network, wall-clock, and hardware dependencies in the default native suite.
- Ensure test-only dependencies never leak into installed targets.
