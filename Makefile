.DEFAULT_GOAL:=help
SHELL:=/bin/bash

.DEFAULT_GOAL := help

#help:	@ List available tasks on this project
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#test:	@ Echo the env vars specific to the project
test:
	echo $(TEAM)-$(ENV)-$(AWS_REGION)
