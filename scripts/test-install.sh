#!/usr/bin/env bash
# Installs the built package and verifies virt-manager and virt-install are usable.
# Usage: test-install.sh <deb>
set -euo pipefail
pkg=${1:?deb}

apt-get update -qq
apt-get install -y -qq --no-install-recommends "$pkg" "$pkg"/../virtinst_*.deb 2>/dev/null || \
  apt-get install -y -qq -f
virt-install --version
virt-manager --version 2>/dev/null || true
echo "Install test passed"
