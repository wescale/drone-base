# drone-base
Set the base infrastructure to work with Drone.io

## Set the workstation
```
docker build -t drone-base . && \
docker run -it \
  -v $(pwd):/userdata \
  -e 'TEAM=team' \
  -e 'ENV=env' \
  -e 'AWS_ACCESS_KEY_ID=id' \
  -e 'AWS_SECRET_ACCESS_KEY=secret' \
  --name drone-base \
  drone-base bash
```
