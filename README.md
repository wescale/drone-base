# drone-base
Set the base infrastructure to work with Drone.io

## Launch the workstation
```
docker build -t drone-base . && \
docker run -it \
  -v $(pwd):/userdata \
  -e 'GROUP=group' \
  -e 'ENV=env' \
  -e 'AWS_ACCESS_KEY_ID=id' \
  -e 'AWS_SECRET_ACCESS_KEY=secret' \
  -e 'AWS_REGION=eu-west-1' \
  --name drone-base \
  drone-base bash
```

## Initialise the S3 bucket to store the tfstate files
```
cd terraform/aws/bootstrap
terraform init
terraform plan -var=group=$GROUP -var=env=$ENV -var=region=$AWS_REGION -state=$GROUP-$ENV.$AWS_REGION.tfstate
terraform apply -var=group=$GROUP -var=env=$ENV -var=region=$AWS_REGION -state=$GROUP-$ENV.$AWS_REGION.tfstate
```

## Set the route53 path

make a hosted zone, like this
`group-env-region.example.com.`
and a A Record set on the wanted IP.
