#!/usr/bin/env bash

set -e

# default values :
help=false
action=apply
region=eu-west-1

while true; do
    case "$1" in
    --help)
        help=true
        shift ;;
    --account)
        account=$2
        group=$(echo $2 | cut -d'-' -f1)
        env=$(echo $2 | cut -d'-' -f2-)
        shift 2 ;;
    --region)
        region=$2
        shift 2 ;;
    --plan)
        action=plan
        shift ;;
    --destroy)
        action=destroy
        shift ;;
    --layer)
        layer=$2
        shift 2 ;;
    '')
        break;;
    *)
        echo "Invalid argument $1";
        exit 1
  esac
done

if [ "$help" = true ] || [ -z "$account" ] || [ -z "$region" ] || [ -z "$action" ]; then
    echo "Usage:
    ./infra-builder-terraform.sh \\
        --account <group>-<env> \\
        --layer 001-vpc \\
        [--region eu-west-1] \\
        [--plan] \\
        [--destroy]"
    exit 1
fi

function terraform_init() {
    terraform init \
        -backend-config "region=${region}" \
        -backend-config "dynamodb_table=${account}-${region}-tfstate-lock" \
        -backend-config "bucket=${account}-${region}-tfstate" \
        -backend-config "key=${layer}.tfstate" \
        -force-copy
}

config_dir="./../../../../configs/${group}/${env}/terraform"
layers_dir="./terraform/layers"

options=""
if [ "$action" = "apply" ] || [ "$action" = "destroy" ]; then
    options="-auto-approve"
fi

cd "$layers_dir/001-main-aws/${layer}"
terraform_init
terraform ${action} ${options} \
    -var-file ${config_dir}/commons.tfvars \
    -var-file ${config_dir}/layer-${layer}.tfvars
