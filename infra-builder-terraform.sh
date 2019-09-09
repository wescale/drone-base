#!/usr/bin/env bash

set -e

while true; do
    case "$1" in
    --team)
        team=$2
        shift 2 ;;
    --env)
        env=$2
        shift 2 ;;
    --provider)
        provider=$2
        shift 2 ;;
    --tfAction)
        tfAction=$2
        shift 2 ;;
    --awsRegion)
        awsRegion=$2
        shift 2 ;;
    # --awsProfile)
    #     awsProfile=$2
    #     shift 2 ;;
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

# TODO: Select one layer / or treat all
# TODO: Add auto-approval option
# TODO: Reverse ls when destroy

if [ -z "$team" ] || [ -z "$env" ] || [ -z "$awsRegion" ] || [ -z "$provider" ] || [ -z "$tfAction" ] || [ -z "$layer" ]; then
    echo "Usage:
    ./infra-builder-terraform.sh \\
        --team jdwsc \\
        --env dev \\
        --provider aws \\
        --awsRegion eu-west-1 \\
        --tfAction plan \\
        --layer 001-vpc \\
        [--awsProfile profileName] \\
        [--layer 001-vpc1]"
    exit 1
fi

tfConfigDir=.secrets/tf-aws-config
layersDir=providers/${provider}/terraform

function tf_init() {
    terraform init \
        -backend-config "region=${awsRegion}" \
        -backend-config "dynamodb_table=${team}-${env}-${awsRegion}-tfstate-lock" \
        -backend-config "bucket=${team}-${env}-${awsRegion}-tfstate" \
        -backend-config "key=${layer}.tfstate" \
        -force-copy
}

# for layer in $(ls "$layersDir"); do
#     # if [[ $layer == '001-vpc' ]] || [[ $layer == '002-asg' ]]; then
#     if [[ $layer == '001-vpc' ]]; then

currentLayerDir="providers/${provider}/terraform/${layer}"
cd $currentLayerDir

tf_init
terraform $tfAction \
    -var-file ./../../../../${tfConfigDir}/${team}-${env}-${provider}-tf-${layer}.tfvars \
    -var-file ./../../../../${tfConfigDir}/${team}-${env}-${provider}-tf.tfvars
#     fi
# done
