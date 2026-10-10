#!/usr/bin/env bash
# Rebuilds the binary .deb packages from a Debian source package, as Launchpad would.
# Usage: rebuild-deb.sh <dsc> <series>
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
dsc=$(readlink -f "${1:?dsc}")
series=${2:?series}
OUT=${OUT:-$ROOT/out}

apt-get update -qq
mk-build-deps --install --remove --tool 'apt-get -y -qq --no-install-recommends' "$dsc"
dir=$OUT/deb/$series
rm -rf "$dir"
mkdir -p "$dir"
dpkg-source -x "$dsc" "$dir/build"
(cd "$dir/build" && dpkg-buildpackage -us -uc -b)
rm -rf "$dir/build"
echo "Built:" "$dir"/*.deb
