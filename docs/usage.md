# Using the sample application and library

The repository builds a small Linux system-information application and a reusable C++ library. The
application is useful as a build, packaging, deployment, and test fixture; replace its behavior when
turning the template into a product.

## Build and run the application

For the normal native development build:

```console
make build
make run
```

The executable is written to `build/dev/bin/embedded-linux-template`. Run it directly when passing
arguments:

```console
./build/dev/bin/embedded-linux-template --help
./build/dev/bin/embedded-linux-template --version
./build/dev/bin/embedded-linux-template --json
```

`make run PRESET=release` runs the optimized native build. Do not use `make run` with an Arm cross
preset unless the host has an explicitly configured compatible execution environment.

## Command-line interface

| Invocation | Result |
| --- | --- |
| `embedded-linux-template` | Prints a human-readable system snapshot |
| `embedded-linux-template --json` | Prints the same fields as one compact JSON object |
| `embedded-linux-template --help` or `-h` | Prints usage and exits |
| `embedded-linux-template --version` | Prints the executable name and project version |

The text output has stable labels:

```text
hostname: target-board
kernel: 6.6.1
machine: aarch64
uptime_seconds: 42
```

JSON output uses `hostname`, `kernel`, `machine`, and `uptime_seconds` fields. Strings are escaped by
the sample implementation, and uptime is truncated to whole seconds for both formats.

The process uses these exit codes:

| Code | Meaning |
| --- | --- |
| `0` | Output, help, or version completed successfully |
| `1` | Required Linux system information could not be read |
| `2` | An unknown command-line option was supplied |

## Linux data sources

The application reads the hostname from `/etc/hostname`, uptime from `/proc/uptime`, and kernel and
machine information from `uname(2)`. A complete snapshot is required; failure to read or parse one
of these values causes exit code `1` instead of partial output.

These interfaces are common on embedded Linux, but a constrained container, unusual root
filesystem, or product-specific security policy can hide them. The library accepts injectable
paths for the proc directory and hostname file so unit tests do not depend on a developer's host.

## Stage an installation

Inspect the files a native installation would provide without changing the host:

```console
make install
find build/release/stage -type f
```

The staged tree contains the executable, core library, public and generated version headers,
license, and CMake package metadata. The executable has an install-relative runtime search path on
Linux so it can locate the staged shared library when `BUILD_SHARED_LIBS=ON`.

Create the portable release archive with `make package`. CPack writes it below
`build/release/packages/`; the archive is a generic staging artifact rather than a replacement for
a distribution-specific `.deb`, `.rpm`, `.ipk`, Yocto recipe, or Buildroot package.

## Consume the installed CMake library

After installation, a CMake consumer can use the exported target:

```cmake
find_package(EmbeddedLinuxTemplate CONFIG REQUIRED)

add_executable(example main.cpp)
target_link_libraries(example PRIVATE embedded_linux_template::core)
target_compile_features(example PRIVATE cxx_std_20)
```

When using the repository's staged installation, point CMake at it:

```console
cmake -S path/to/consumer -B build/consumer -G Ninja \
  -DCMAKE_PREFIX_PATH="$PWD/build/release/stage"
cmake --build build/consumer
```

Run `make consumer-test` to execute the checked-in independent consumer automatically. It catches
export, include path, generated-header, and link-interface mistakes that an in-tree build can miss.
The generated API details are available in {doc}`api`.

## Version behavior

The repository-root `version.txt` is the only version source. Its `vMAJOR.MINOR.PATCH` value is
normalized to `MAJOR.MINOR.PATCH` for CMake, the generated
`embedded_linux_template/version.hpp`, the `--version` output, Conan, and package filenames. The
documentation retains the leading `v` in its sidebar.

Change the source file only as part of a release decision; do not edit generated version headers.
See {doc}`release-management` for the tag and package workflow.

## Replace the sample safely

Keep argument parsing and process lifecycle in `app/`, and put reusable product behavior in a
library target under `src/` with public declarations under `include/`. This separation makes Linux
observations injectable, reduces subprocess-based testing, and gives downstream software an
installable API.

When changing output, options, exit codes, or public C++ symbols, update unit and integration tests,
the API comments, this guide, and the changelog. The architecture and verification expectations are
described in {doc}`architecture` and {doc}`testing`.
