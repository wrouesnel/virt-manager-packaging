FROM docker.io/library/ubuntu:24.04
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
      dpkg-dev debhelper devscripts git ca-certificates && \
    rm -rf /var/lib/apt/lists/*
