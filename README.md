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
terraform plan -var=team=team -var=env=env -var=region=eu-west-1 -state=team-env.eu-west-1.tfstate
terraform apply -var=team=team -var=env=env -var=region=eu-west-1 -state=team-env.eu-west-1.tfstate
```
