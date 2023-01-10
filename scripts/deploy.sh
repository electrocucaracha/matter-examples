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

sudo docker-compose up -d
trap 'sudo docker-compose down' EXIT
_wait_chip_apps

# Provisioning
_exec_chip_tool pairing onnetwork-long 0x11 20202021 3840

# Light on
_exec_chip_tool onoff on 0x11 1

# Light off
_exec_chip_tool onoff off 0x11 1

sudo docker-compose logs
