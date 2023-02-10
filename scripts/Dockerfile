FROM ubuntu:22.04 as builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  git=1:2.34.1-1ubuntu1.6 \
  gcc=4:11.2.0-1ubuntu1 \
  g++=4:11.2.0-1ubuntu1 \
  pkg-config=0.29.2-1ubuntu3 \
  libssl-dev=3.0.2-0ubuntu1.8 \
  libdbus-1-dev=1.12.20-2ubuntu4.1 \
  libglib2.0-dev=2.72.4-0ubuntu1 \
  libavahi-client-dev=0.8-5ubuntu5 \
  ninja-build=1.10.1-1 \
  python3-venv=3.10.6-1~22.04 \
  python3-dev=3.10.6-1~22.04 \
  python3-pip=22.0.2+dfsg-1ubuntu0.1 \
  unzip=6.0-26ubuntu3.1 \
  libgirepository1.0-dev=1.72.0-1 \
  libcairo2-dev=1.16.0-5ubuntu2 \
  libreadline-dev=8.1.2-1 \
  wget=1.21.2-2ubuntu1 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone --depth 1 https://github.com/project-chip/connectedhomeip.git --branch v1.0.0 \
  && ./connectedhomeip/scripts/checkout_submodules.py --shallow --platform linux \
  && ./connectedhomeip/scripts/build/gn_bootstrap.sh

WORKDIR /opt/connectedhomeip/scripts/examples/
RUN ./gn_build_example.sh ../../examples/chip-tool /tmp/chip-tool/ \
  && ./gn_build_example.sh ../../examples/lighting-app/linux /tmp/lighting-app/

RUN wget -q https://github.com/kubeedge/kubeedge/releases/download/v1.13.0/keadm-v1.13.0-linux-amd64.tar.gz -O - | tar -xz --strip-components=2 -C /tmp

FROM ubuntu:22.04 as chip-tool

COPY --from=builder /tmp/chip-tool /usr/local/bin/

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  libssl-dev=3.0.2-0ubuntu1.8 \
  libdbus-1-dev=1.12.20-2ubuntu4.1 \
  && rm -rf /var/lib/apt/lists/*

CMD ["/usr/local/bin/chip-tool"]

FROM ubuntu:22.04 as chip-lighting-app

COPY --from=builder /tmp/lighting-app /usr/local/bin/
COPY --from=builder /tmp/keadm /usr/local/bin/
COPY lighting-app.service /etc/systemd/system/
ADD https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/v1.5.4505/files/docker/systemctl3.py /usr/bin/systemctl

RUN apt-get update && apt-get install -y -qq --no-install-recommends \
  libssl-dev=3.0.2-0ubuntu1.8 \
  libdbus-1-dev=1.12.20-2ubuntu4.1 \
  python3=3.10.6-1~22.04 \
  && rm -rf /var/lib/apt/lists/* \
  && chmod +x /usr/bin/systemctl \
  && systemctl enable lighting-app

CMD ["/usr/bin/systemctl"]
