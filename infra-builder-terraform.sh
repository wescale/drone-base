#!/usr/bin/env bash

set -e

# default values :
action=apply
region=eu-west-1

while true; do
    case "$1" in
    --account)
        group=$2
        shift 2 ;;
    --region)
        region=$2
        shift 2 ;;
    --plan)
        action=plan
        shift 2 ;;
    --destroy)
        action=destroy
        shift 2 ;;
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

if [ -z "$account" ] || [ -z "$region" ] || [ -z "$action" ]; then
    echo "Usage:
    ./infra-builder-terraform.sh \\
        --account <group>-<env> \\
        --layer 001-vpc1 \\
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

config_dir=.secrets/tf-aws-config
layer_dir="providers/aws/terraform/${layer}"
# layers_dir=providers/aws/terraform

# for the selected layer :
cd $layer_dir
terraform_init
terraform $action \
    -var-file ./../../../../${config_dir}/${account}-aws-tf-${layer}.tfvars \
    -var-file ./../../../../${config_dir}/${account}-aws-tf.tfvars
