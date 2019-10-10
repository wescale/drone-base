#!/bin/bash
set -e

CURRENT_DIR=$(pwd)

cd terraform/layers/001-main-aws/002-asg && \
terraform output ansible_inventory > ${CURRENT_DIR}/inventory
