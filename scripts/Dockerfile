FROM ubuntu:20.04 as builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  git=1:2.25.1-1ubuntu3.6 \
  gcc=4:9.3.0-1ubuntu2 \
  g++=4:9.3.0-1ubuntu2 \
  pkg-config=0.29.1-0ubuntu4 \
  libssl-dev=1.1.1f-1ubuntu2.16 \
  libdbus-1-dev=1.12.16-2ubuntu2.3 \
  libglib2.0-dev=2.64.6-1~ubuntu20.04.4 \
  libavahi-client-dev=0.7-4ubuntu7.1 \
  ninja-build=1.10.0-1build1 \
  python3-venv=3.8.2-0ubuntu2 \
  python3-dev=3.8.2-0ubuntu2 \
  python3-pip=20.0.2-5ubuntu1.6 \
  unzip=6.0-25ubuntu1.1 \
  libgirepository1.0-dev=1.64.1-1~ubuntu20.04.1 \
  libcairo2-dev=1.16.0-4ubuntu1 \
  libreadline-dev=8.0-4 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone --depth 1 https://github.com/project-chip/connectedhomeip.git --branch v1.0.0 \
  && ./connectedhomeip/scripts/checkout_submodules.py --shallow --platform linux \
  && ./connectedhomeip/scripts/build/gn_bootstrap.sh

WORKDIR /opt/connectedhomeip/scripts/examples/
RUN ./gn_build_example.sh ../../examples/chip-tool /tmp/chip-tool/ \
  && ./gn_build_example.sh ../../examples/lighting-app/linux /tmp/lighting-app/

FROM ubuntu:20.04 as chip-tool

COPY --from=builder /tmp/chip-tool /usr/local/bin/

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  libssl-dev=1.1.1f-1ubuntu2.16 \
  libdbus-1-dev=1.12.16-2ubuntu2.3 \
  && rm -rf /var/lib/apt/lists/*

CMD ["/usr/local/bin/chip-tool"]

FROM ubuntu:20.04 as chip-lighting-app

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  libssl-dev=1.1.1f-1ubuntu2.16 \
  libdbus-1-dev=1.12.16-2ubuntu2.3 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/lighting-app /usr/local/bin/

CMD ["/usr/local/bin/chip-lighting-app"]
