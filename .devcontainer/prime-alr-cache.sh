#!/usr/bin/env bash
set -euo pipefail

gnat_version="${1:?usage: prime-alr-cache.sh <gnat-version> <gprbuild-version>}"
gprbuild_version="${2:?usage: prime-alr-cache.sh <gnat-version> <gprbuild-version>}"

alr settings --global --set toolchain.assistant false
alr toolchain --select --disable-assistant \
  "gnat_native=${gnat_version}" "gprbuild=${gprbuild_version}"

prime_dir="$(mktemp -d)"
trap 'rm -rf "${prime_dir}"' EXIT
cat > "${prime_dir}/alire.toml" <<EOF
name = "prime"
version = "0.1.0"
description = "cache primer"
maintainers = ["P <p@example.com>"]
maintainers-logins = ["p"]

[[depends-on]]
gnatprove = "^${gnat_version}"
EOF

(cd "${prime_dir}" && alr -n update)

alr version
