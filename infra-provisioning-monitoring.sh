#!/bin/bash
set -e

if [[ -z "$1" ]]; then
    echo "drone_secret is missing"
    exit 1
fi

ansible-playbook ansible/setup-monitoring.yml -e drone_secret=$1
