# Code metrics

The metrics page combines repository size, C and C++ complexity, test coverage, and generated API
inventory. These measurements are review aids: they point to code worth understanding, but they do
not determine correctness, productivity, security, or design quality by themselves.

Generate the reports directly with:

```console
make metrics
```

The command writes four Markdown fragments and a complete machine-readable `summary.json` below
`build/metrics/`. `make docs` also generates the metrics after Doxygen and before Sphinx, so the
published page is refreshed during every documentation build.

Line counts and complexity require `cloc` and the Python `lizard` package. Run `make setup-native`
or use the development container for the complete environment; `make bootstrap` installs Lizard but
does not install the system `cloc` executable.

## Reading the reports

### Lines of code

`cloc` classifies blank, comment, and code lines by language and file. The generator excludes
dependency, cache, version-control, virtual-environment, and build-output directories so the report
describes repository-owned inputs rather than downloaded or generated material.

Line counts are useful for tracking the distribution and review surface of a project. A larger
count is neither inherently better nor worse, and generated tables should not be used to compare
individual productivity.

```{include} ../build/metrics/cloc-report.md
```

### C and C++ complexity

Lizard analyzes the C and C++ files discovered by the line-count pass. It reports logical lines of
code (NLOC), tokens, parameter counts, and cyclomatic complexity (CCN) for each function. CCN
approximates the number of independent control-flow paths; higher values usually require more test
cases and more reviewer attention.

The report highlights functions above CCN 10 or 100 NLOC. These are review indicators, not build
gates. A flagged state machine, parser, or carefully isolated algorithm may be appropriate, while a
lower-scoring function can still contain a serious defect. Use the table to ask whether a function
has one responsibility, explicit error paths, focused tests, and understandable invariants.

```{include} ../build/metrics/complexity-report.md
```

### Test coverage

The coverage section reads `build/coverage/coverage-summary.json`, which gcovr creates during
`make coverage`. It contains overall and per-file line, function, and branch percentages for the
instrumented native test run.

Run coverage before metrics when a current report is required:

```console
make coverage
make metrics
```

The coverage command enforces at least 85 percent overall line coverage. Function and branch
figures remain diagnostic rather than separate gates. Missing coverage data does not make a
documentation-only build fail; the generated fragment explains that `make coverage` must run
first.

Coverage measures which instrumented paths executed, not whether assertions were meaningful. Add
tests for failure handling, boundaries, state transitions, and Linux error cases before adding
incidental calls solely to increase a percentage. See {doc}`testing`.

```{include} ../build/metrics/coverage-report.md
```

### Doxygen API inventory

The API metrics summarize compounds and unique members emitted in Doxygen's `index.xml`, grouped by
symbol kind. During `make docs`, Doxygen runs first, so the inventory reflects the same XML consumed
by Breathe on {doc}`api`.

The index includes files, pages, and namespaces as well as types and members; it is not limited to
the installed API. An emitted-symbol count is therefore not an API-size or documentation
completeness score. The strict Doxygen configuration is the actual documentation gate:
undocumented public declarations and invalid comments fail the build. Use the kind breakdown to
spot changes that deserve a closer API and compatibility review.

When `make metrics` runs without existing Doxygen XML, this fragment reports the missing input. Run
`make docs` to regenerate Doxygen and produce the complete current API section.

```{include} ../build/metrics/api-report.md
```

## Using metrics responsibly

Review trends and context instead of optimizing a single number:

- A rising CCN can identify a refactoring or additional-test opportunity.
- A large public API increases compatibility, documentation, and support obligations.
- A coverage decrease can reveal an untested branch, but unchanged coverage can still hide weak
  assertions.
- Line-count growth can be justified by clearer separation, tests, or documentation.

Never edit the generated fragments or `summary.json`. Change source, tests, documentation, or
`scripts/generate-metrics.py`, then regenerate the reports. Generated metrics remain below
`build/` and are intentionally excluded from Git.
