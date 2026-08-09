# Cross-compiling

The repository includes representative GNU/Linux cross configurations for 64-bit Arm and Armv7
hard-float targets. They demonstrate the CMake toolchain boundary without claiming compatibility
with every board support package.

## Toolchain expectations

The standard presets expect these compiler families on the build host:

| Preset | Compiler prefix | Typical target |
| --- | --- | --- |
| `arm64-release` | `aarch64-linux-gnu-` | 64-bit Arm GNU/Linux |
| `armv7-release` | `arm-linux-gnueabihf-` | 32-bit Arm GNU/Linux with hard-float ABI |

The linker, C library, loader, kernel ABI, and third-party libraries must match the target root
filesystem. A matching compiler alone is not enough.

On Debian or Ubuntu, `make setup-native` installs both compiler families, Ninja, QEMU user-mode,
and the related native tooling. The development container provides the same cross-build commands.

## Standard cross-builds

```console
make cross-arm64
make cross-armv7
```

Or invoke the presets directly:

```console
cmake --preset arm64-release
cmake --build --preset arm64-release

cmake --preset armv7-release
cmake --build --preset armv7-release
```

Inspect the result before deployment:

```console
file build/arm64-release/bin/embedded-linux-template
readelf -h build/arm64-release/bin/embedded-linux-template
readelf -d build/arm64-release/bin/embedded-linux-template
```

## Using a sysroot

Set `EMBEDDED_SYSROOT` when the cross-compiler should resolve target headers and libraries from a
specific root filesystem:

```console
export EMBEDDED_SYSROOT=/opt/target-sdk/sysroots/aarch64-target-linux
cmake --preset arm64-release
cmake --build --preset arm64-release
```

The directory must be a compiler-compatible sysroot, not an arbitrary copy of `/` from a device.
Reconfigure from a fresh preset build directory after changing sysroots or compiler families; CMake
caches toolchain identity.

## Vendor SDKs

Yocto Project SDKs, Buildroot SDKs, and board vendors commonly provide an environment setup script
or CMake toolchain. Prefer the SDK-provided toolchain when it encodes ABI flags, tuning, sysroot
layout, and search behavior.

Create an untracked `CMakeUserPresets.json` for machine-specific paths:

```json
{
  "version": 6,
  "configurePresets": [
    {
      "name": "vendor-release",
      "displayName": "Vendor SDK release",
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build/${presetName}",
      "toolchainFile": "/opt/vendor-sdk/cmake/toolchain.cmake",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release",
        "BUILD_TESTING": "OFF"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "vendor-release",
      "configurePreset": "vendor-release"
    }
  ]
}
```

`cmake/toolchains/custom-sdk.cmake.example` documents the variables needed when an SDK does not
provide its own file. Do not commit local SDK installation paths.

## Running cross-built tests

Normal unit tests execute on the native build host. Cross presets disable tests unless a compatible
emulator is configured because CMake cannot execute a target binary directly.

QEMU user-mode can provide a smoke test when its loader and library path match the sysroot. It does
not emulate the target kernel configuration, devices, timing, or peripherals. Always finish with
tests on representative hardware.

## Remote debugging

The VS Code remote launch configuration uses an unstripped local binary and a target-side
`gdbserver`. Ensure that:

- the local executable is exactly the one deployed to the device;
- GDB knows the target sysroot and shared-library paths;
- the debug port is reachable only through a trusted network or tunnel; and
- deployment and process control are performed explicitly.

## Explicit deployment helper

The `deploy` Make target wraps a deliberately explicit SSH/rsync operation. It defaults to the
Arm64 release binary and requires `TARGET_HOST`:

```console
make cross-arm64
TARGET_HOST=user@device.local \
TARGET_DIR=/opt/embedded-linux-template/bin \
make deploy
```

Override `BINARY` to deploy another build. Set `TARGET_SERVICE` only when the target has a matching
systemd unit and the deployment account is authorized to restart it. The helper validates its
inputs, but it cannot determine whether a device, destination, or service is safe for a particular
project. Review the command and preserve a rollback path before using it on production hardware.
