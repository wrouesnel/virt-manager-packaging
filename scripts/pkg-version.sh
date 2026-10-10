#!/usr/bin/env bash
# Prints "EPOCH VERSION RELEASE ORIG_VERSION" for the virt-manager source tree at the given path.
# The version is derived from the git tag (VM_REF) if set, otherwise from meson.build.
# EPOCH: Debian epoch (Ubuntu's virt-manager uses epoch 1)
# VERSION: Debian-safe upstream version ('+' replaced by '~')
# RELEASE: PKG_RELEASE (default 1)
# ORIG_VERSION: the raw version for the orig tarball directory name ('+' replaced by '.')
set -euo pipefail
srcdir=${1:?source directory}

if [ -n "${VM_REF:-}" ]; then
  raw=${VM_REF#v}
else
  raw=$(sed -n "s/.*version: *'\([^']*\)'.*/\1/p" "$srcdir/meson.build" | head -1)
  tag=$(git -C "$srcdir" describe --tags --exact-match 2>/dev/null || true)
  if [ -n "$tag" ]; then
    raw=${tag#v}
  fi
fi

epoch=1
version=${raw//+/\~}
orig_version=${raw//+/.}
release=${PKG_RELEASE:-1}
echo "$epoch $version $release $orig_version"
