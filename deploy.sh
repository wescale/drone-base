#!/usr/bin/env bash

set -ex

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
    --awsRegion)
        awsRegion=$2
        shift 2 ;;
    # --awsProfile)
    #     awsProfile=$2
    #     shift 2 ;;
    # --layer)
    #     layer=$2
    #     shift 2 ;;
    '')
        break;;
    *)
        echo "Invalid argument $1";
        exit 1
  esac
done

if [ -z "$team" ] && [ -z "$env" ] && [ -z "$region" ] && [ -z "$provider" ]; then
    echo "Usage:
    ./deploy.sh \\
        --team jdwsc \\
        --env dev \\
        --provider aws \\
        --awsRegion eu-west-1 \\
        --awsProfile profileName \\
        --layer 001-vpc1 \\
        [--test] \\
        [--cfn-nag]"
    exit 1
fi

tfConfigDir=.secrets/tf-config
layersDir=providers/${provider}/terraform

function tf_init() {
    terraform init \
        -backend-config "region=${awsRegion}" \
        -backend-config "dynamodb_table=${team}-${env}-${awsRegion}-tfstate-lock" \
        -backend-config "bucket=${team}-${env}-${awsRegion}-tfstate" \
        -backend-config "key=${layer}.tfstate" \
        -force-copy
}

for layer in $(ls "$layersDir"); do
    if [[ $layer != '000-tfstate' ]]; then

        currentLayerDir="providers/${provider}/terraform/${layer}"
        cd $currentLayerDir

        tf_init
        terraform plan \
            -var-file ./../../../../${tfConfigDir}/${team}-${env}-${provider}-tf-${layer}.tfvars \
            -var-file ./../../../../${tfConfigDir}/${team}-${env}-${provider}-tf.tfvars
    fi
done
