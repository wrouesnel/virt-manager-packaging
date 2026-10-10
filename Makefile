# Builds virt-manager source packages for the Launchpad PPA and tests them in containers (podman).
#
#   make deb-source     build the Debian source packages (for the PPA) in out/deb-source/<series>/
#   make test           rebuild the binary packages from the source packages and install-test them
#   make test-<target>  the same for one target: noble, resolute
#   make all            everything above
#
# Variables: see upstream.env (VM_REPO, VM_REF), and
#   PKG_MAINTAINER packager identity "Name <email>" (default: git config user.name / user.email)
#   PKG_RELEASE    package release number (default 1)

include upstream.env
export VM_REPO VM_REF

PODMAN ?= podman
PKG_MAINTAINER ?= $(shell git config user.name) <$(shell git config user.email)>
PKG_RELEASE ?= 1
IMAGE_PREFIX ?= localhost/virt-manager-pkg

DEB_SERIES := noble resolute
image_noble := docker.io/library/ubuntu:24.04
image_resolute := docker.io/library/ubuntu:26.04

DEB_TOOLS_IMAGE := $(IMAGE_PREFIX)/deb-tools

latest = "$$(ls -1 $(1) 2>/dev/null | sort | tail -1)"

RUN := $(PODMAN) run --rm --security-opt label=disable -v $(CURDIR):/pkg -w /pkg \
	-e PKG_MAINTAINER="$(PKG_MAINTAINER)" -e PKG_RELEASE=$(PKG_RELEASE)

.PHONY: all images deb-source test $(addprefix test-,$(DEB_SERIES)) clean

all: deb-source test

images:
	$(PODMAN) build -t $(DEB_TOOLS_IMAGE) -f containers/deb-tools.Containerfile containers

deb-source: images
	$(RUN) $(DEB_TOOLS_IMAGE) scripts/build-deb-source.sh $(DEB_SERIES)

test: $(addprefix test-,$(DEB_SERIES))

$(addprefix test-,$(DEB_SERIES)): test-%:
	$(RUN) $(image_$*) scripts/rebuild-deb.sh $(call latest,out/deb-source/$*/virt-manager_*.dsc) $*
	$(RUN) $(image_$*) scripts/test-install.sh $(call latest,out/deb/$*/virt-manager_*_all.deb)

clean:
	rm -rf out work
