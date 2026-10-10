#!/usr/bin/env bash
# Prints "VERSION RELEASE" for the virt-manager source tree at the given path.
# VERSION: the meson project version with '+' replaced by '~' (5.1.0+wrouesnel.1 -> 5.1.0~wrouesnel.1)
# RELEASE: PKG_RELEASE (default 1)
set -euo pipefail
srcdir=${1:?source directory}
version=$(sed -n "s/.*version: *'\([^']*\)'.*/\1/p" "$srcdir/meson.build" | head -1)
# the tag may carry +wrouesnel.N: replace '+' with '~' for Debian version ordering
version=${version//+/\~}
release=${PKG_RELEASE:-1}
echo "$version $release"
