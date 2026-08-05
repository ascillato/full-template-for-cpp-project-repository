# Security Policy

## Supported versions

This repository is a template rather than a deployed product. Security fixes are applied to the
default branch and, when releases exist, to the latest supported release line.

| Version | Supported |
| --- | --- |
| `main` / unreleased | Yes |
| Latest release | Yes |
| Older releases | No |

Projects created from this template maintain their own support and disclosure policies.

## Report a vulnerability

Do not open a public issue for a suspected vulnerability. Use GitHub's
[private vulnerability reporting form](https://github.com/ascillato/full-template-for-cpp-project-repository/security/advisories/new).

Include, when available:

- the affected revision or release;
- a concise description and expected security impact;
- reproduction steps or a minimal proof of concept;
- relevant native or target architecture, compiler, libc, kernel, and build preset;
- whether the issue affects the template infrastructure, generated projects, or both; and
- any suggested mitigation or disclosure constraints.

Do not include secrets, production credentials, personal information, or proprietary SDK files.

## Response process

Maintainers will acknowledge a complete report, assess its scope, and coordinate remediation and
disclosure. Timing depends on severity, reproducibility, affected release lines, and whether an
upstream tool or dependency is involved. Reporters are asked to allow a reasonable remediation
period before public disclosure.

If the issue belongs to an upstream compiler, build tool, library, GitHub Action, container image,
or vendor SDK, maintainers may coordinate with that project and track the mitigation here.

## Embedded deployment considerations

The template cannot guarantee the security of a generated device image. Derived projects must
assess their own:

- secure boot, signing, rollback, and update strategy;
- process privileges, capabilities, sandboxing, and service configuration;
- remote access, debugging, deployment credentials, and network exposure;
- compiler hardening supported by the actual target libc and toolchain;
- dependency, kernel, bootloader, BSP, and root-filesystem update policy; and
- storage and handling of device-specific secrets.

The sample application is not a security boundary and should not be deployed unchanged as a
privileged service.
