# drone-base
Set the base infrastructure to work with Drone.io

## Launch the workstation
```
docker build -t drone-base . && \
docker run -it \
  -v $(pwd):/userdata \
  -e 'TEAM=team' \
  -e 'ENV=env' \
  -e 'AWS_ACCESS_KEY_ID=id' \
  -e 'AWS_SECRET_ACCESS_KEY=secret' \
  -e 'AWS_REGION=eu-west-1' \
  --name drone-base \
  drone-base bash
```

## Initialise the S3 bucket to store the tfstate files
```
cd providers/aws/terraform/000-tfstate
terraform init
terraform plan -var=team=$TEAM -var=env=$ENV -var=region=$AWS_REGION -state=$TEAM-$ENV.$AWS_REGION.tfstate
terraform apply -var=team=$TEAM -var=env=$ENV -var=region=$AWS_REGION -state=$TEAM-$ENV.$AWS_REGION.tfstate
```

## Set the route53 path

make a hosted zone, like this
`team-env-awsRegion.example.com.`
and a A Record set on the wanted IP.
