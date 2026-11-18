FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG ALR_VERSION=2.1.1
ARG GNAT_VERSION=16.1.0
ARG GPRBUILD_VERSION=26.0.1

RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      arm64) alr_arch=aarch64 ;; \
      *)     alr_arch=x86_64 ;; \
    esac; \
    curl -fsSL -o /tmp/alr.zip \
      "https://github.com/alire-project/alire/releases/download/v${ALR_VERSION}/alr-${ALR_VERSION}-bin-${alr_arch}-linux.zip"; \
    unzip -q /tmp/alr.zip -d /tmp/alr; \
    install -m 755 /tmp/alr/bin/alr /usr/local/bin/alr; \
    rm -rf /tmp/alr /tmp/alr.zip

# alr TAB completion for interactive shells (official upstream script, vendored).
# /etc/bash.bashrc is sourced by interactive login AND non-login shells on
# Ubuntu, and returns early for non-interactive shells, so scripts/CI are
# unaffected.
COPY alr-completion.bash /usr/local/share/alr-completion.bash
RUN echo '[ -f /usr/local/share/alr-completion.bash ] && . /usr/local/share/alr-completion.bash' >> /etc/bash.bashrc

USER vscode

ENV HOME=/home/vscode
WORKDIR /home/vscode

COPY --chmod=0755 prime-alr-cache.sh /tmp/prime-alr-cache.sh
RUN /tmp/prime-alr-cache.sh "${GNAT_VERSION}" "${GPRBUILD_VERSION}"
