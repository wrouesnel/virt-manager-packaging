#!/usr/bin/env bash
# Builds the Debian source packages (for the Launchpad PPA) from the virt-manager fork, one per Ubuntu series:
# out/deb-source/<series>/virt-manager_<version>-<release>~<series>1{.dsc,.debian.tar.xz,_source.changes}
# and the orig tarball.
# Usage: build-deb-source.sh <series>...
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT/upstream.env"
shift 0  # no archive argument, unlike podman-desktop

[ $# -gt 0 ] || { echo "no Ubuntu series given" >&2; exit 1; }
: "${PKG_MAINTAINER:?PKG_MAINTAINER must be set (Name <email>)}"

OUT=${OUT:-$ROOT/out}
WORK=${WORK:-$ROOT/work}
SRC=$WORK/src

mkdir -p "$OUT" "$WORK"
rm -rf "$SRC"
git clone --quiet --filter=blob:none "$VM_REPO" "$SRC"
git -C "$SRC" checkout --quiet "$VM_REF"
COMMIT=$(git -C "$SRC" rev-parse --short HEAD)

read -r version release < <("$ROOT/scripts/pkg-version.sh" "$SRC")

# strip debian-unfriendly characters from the directory name: replace ~ with .
orig_version=${version//\~/.}
orig_dir=virt-manager-$orig_version

# create the orig tarball from the checked-out source
ORIG=$OUT/virt-manager_$version.orig.tar.gz
(cd "$SRC/.." && mv src "$orig_dir" && \
 tar --sort=name --owner=0 --group=0 --numeric-owner \
   --exclude=.git -czf "$ORIG" "$orig_dir" && \
 mv "$orig_dir" src)

for series in "$@"; do
  debversion="$version-$release~${series}1"
  dir=$OUT/deb-source/$series
  rm -rf "$dir"
  mkdir -p "$dir"

  cp "$ORIG" "$dir/"
  tar -C "$dir" -xzf "$ORIG"
  tree=$dir/$orig_dir

  cp -a "$ROOT/deb/debian" "$tree/debian"
  sed "s|@MAINTAINER@|$PKG_MAINTAINER|" "$tree/debian/control.in" > "$tree/debian/control"
  rm "$tree/debian/control.in"

  cat > "$tree/debian/changelog" <<CHANGELOG
virt-manager ($debversion) $series; urgency=medium

  * virt-manager $orig_version ($COMMIT) from
    https://github.com/wrouesnel/virt-manager

 -- $PKG_MAINTAINER  $(LC_ALL=C date -u -R)
CHANGELOG

  (cd "$tree" && dpkg-buildpackage -S -sa -d -us -uc >/dev/null)
  rm -rf "$tree"
  ls "$dir"/*_source.changes
done
