#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2023
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o pipefail
set -o errexit
set -o nounset
if [[ ${DEBUG:-false} == "true" ]]; then
    set -o xtrace
fi

NODE_ID_TO_ASSIGN=0x11
ENDPOINT_ID=1

function _exec_chip_tool {
    sudo docker exec "$(sudo docker ps --filter 'name=.*cli' -q)" /usr/local/bin/chip-tool "$@"
}

function _wait_chip_apps {
    local max_attempts=5
    for svc in $(sudo docker-compose ps -aq); do
        attempt_counter=0
        until [ "$(sudo docker inspect "$svc" --format='{{.State.Running}}')" == "true" ]; do
            if [ ${attempt_counter} -eq ${max_attempts} ]; then
                echo "Max attempts reached for waiting to gitea containers"
                exit 1
            fi
            attempt_counter=$((attempt_counter + 1))
            sleep $((attempt_counter * 5))
        done
    done
}

# Provision Lighting Application service
sudo docker-compose up -d
trap 'sudo docker-compose down' EXIT
_wait_chip_apps

# Download keadm
if ! command -v keadm >/dev/null; then
    container_id=$(sudo docker ps | grep "lighting-app" | awk '{print $1}')
    sudo docker cp "$container_id:/usr/local/bin/keadm" /usr/local/bin/keadm
    keadm completion bash | sudo tee /etc/bash_completion.d/kind >/dev/null
fi

# Commissioning:
# Discover devices with long discriminator 3840 and try to pair with the first
# one it discovers using the provided setup code.
_exec_chip_tool pairing onnetwork-long "${NODE_ID_TO_ASSIGN}" 20202021 3840

# Light on
_exec_chip_tool onoff on "${NODE_ID_TO_ASSIGN}" "${ENDPOINT_ID}"

# Light off
_exec_chip_tool onoff off "${NODE_ID_TO_ASSIGN}" "${ENDPOINT_ID}"

# Forget the commissioned device
_exec_chip_tool pairing unpair "${NODE_ID_TO_ASSIGN}"

sudo docker-compose logs
