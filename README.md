# virt-manager packaging

Builds Debian source packages from the
[wrouesnel/virt-manager](https://github.com/wrouesnel/virt-manager) fork and
publishes them to the Launchpad PPA
[`ppa:w-rouesnel/virt-manager`](https://launchpad.net/~w-rouesnel/+archive/ubuntu/virt-manager).

## Installing

```bash
sudo add-apt-repository ppa:w-rouesnel/virt-manager
sudo apt install virt-manager-ext
```

## Target releases

| Ubuntu | Codename |
|---|---|
| 24.04 LTS | noble |
| 26.04 LTS | resolute |

## Building locally

Requires `podman` (or `docker`, set `PODMAN=docker`).

```bash
make deb-source          # build source packages for all series
make test                # rebuild and install-test each series in containers
make test-noble           # test one series
make clean               # remove out/ and work/
```

## How it works

1. `scripts/build-deb-source.sh` clones the fork at the ref in `upstream.env`,
   creates an orig tarball, overlays `deb/debian/`, and runs
   `dpkg-buildpackage -S` for each Ubuntu series.
2. The GitHub Actions workflow builds the source packages on every push, tests
   them by rebuilding as binary packages in containers of each target, and on
   version tags signs and uploads to the PPA.
3. Launchpad builds the binary packages from the source packages in its own
   builders.

## Releasing a new version

1. Update `VM_REF` in `upstream.env` to the new tag (e.g. `v5.1.0+wrouesnel.2`).
2. Commit and tag this repo as `v<version>` (e.g. `v5.1.0-wrouesnel.2`).
3. Push the tag. The CI workflow signs and uploads to the PPA.

## CI secrets

| Secret / Variable | Description |
|---|---|
| `PACKAGE_SIGNING_KEY` | Armoured GPG private key for Launchpad uploads |
| `PACKAGE_SIGNING_KEY_PASSPHRASE` | Its passphrase |
| `PACKAGE_SIGNING_KEY_FINGERPRINT` | (variable) Key fingerprint |
| `PKG_MAINTAINER` | (variable) `Name <email>` for the changelog |
| `PPA` | (variable, default `ppa:w-rouesnel/virt-manager`) |
