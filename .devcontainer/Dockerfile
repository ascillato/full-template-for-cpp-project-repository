FROM ubuntu:26.04@sha256:678c6550cc43645e08669028bc177f50be4e7c5b8cca677067b1914d4afc7a03

ARG DEBIAN_FRONTEND=noninteractive
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# OS package revisions intentionally follow the pinned Ubuntu 24.04 repository.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        bash-completion \
        build-essential \
        ca-certificates \
        ccache \
        clang \
        clang-tidy \
        clang-tools \
        clangd \
        cloc \
        cmake \
        cppcheck \
        curl \
        doxygen \
        file \
        g++-aarch64-linux-gnu \
        g++-arm-linux-gnueabihf \
        gcc-aarch64-linux-gnu \
        gcc-arm-linux-gnueabihf \
        gdb \
        gdb-multiarch \
        git \
        graphviz \
        lldb \
        ninja-build \
        openssh-client \
        pkg-config \
        python3 \
        python3-pip \
        python3-venv \
        qemu-user \
        rsync \
        shellcheck \
        sudo \
        unzip \
        xz-utils \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements-dev.txt docs/requirements.txt /tmp/python-requirements/

RUN python3 -m venv /opt/cpp-template-tools \
    && /opt/cpp-template-tools/bin/python -m pip install \
        --disable-pip-version-check \
        --no-cache-dir \
        --requirement /tmp/python-requirements/requirements-dev.txt \
        --requirement /tmp/python-requirements/requirements.txt \
    && rm -rf /tmp/python-requirements

# Ubuntu 24.04 reserves UID/GID 1000 for its ubuntu account. Reclaim the requested
# IDs so the default devcontainer arguments work and bind-mounted files keep the
# host developer's ownership.
RUN set -eux; \
    if [[ "${USER_UID}" -eq 0 || "${USER_GID}" -eq 0 ]]; then \
        echo "USER_UID and USER_GID must be non-root IDs" >&2; \
        exit 1; \
    fi; \
    existing_user="$(getent passwd "${USER_UID}" | cut -d: -f1 || true)"; \
    if [[ -n "${existing_user}" ]]; then \
        userdel "${existing_user}"; \
    fi; \
    existing_group="$(getent group "${USER_GID}" | cut -d: -f1 || true)"; \
    if [[ -n "${existing_group}" ]]; then \
        groupdel "${existing_group}"; \
    fi; \
    groupadd --gid "${USER_GID}" vscode; \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash vscode; \
    printf 'vscode ALL=(root) NOPASSWD:ALL\n' > /etc/sudoers.d/vscode; \
    chmod 0440 /etc/sudoers.d/vscode; \
    mkdir -p /home/vscode/.cache/ccache /home/vscode/.conan2; \
    chown -R "${USER_UID}:${USER_GID}" /home/vscode

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=/opt/cpp-template-tools/bin:${PATH} \
    CCACHE_DIR=/home/vscode/.cache/ccache \
    CONAN_HOME=/home/vscode/.conan2

USER ${USER_UID}
WORKDIR /workspaces
