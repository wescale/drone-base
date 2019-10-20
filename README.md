# drone-base

Set the base of the infrastructure to work with Drone.io

## Requirements

* bash v4+
* Docker v19.03.2+
* aws cli v1.16.169+, with an aws access configured
* A ssh key created for the project

## Deployment

Before all, you should set your AWS environnement with the appropriate configuration.  

You have a config foler you should define, according to this template files :

```
configs/
└── mygroup
    └── myenv
        └── terraform
            ├── commons.tfvars
            ├── layer-001-vpc.tfvars
            └── layer-002-asg.tfvars
```

Some variables you should define to your case :
* group : the name of the logical entity you work on, feel free
* env : the name of the environment (dev, prod, for instance)
* accountname : group-env 

For Ansible deployments, you have to rename all.template.yml to all.yml and add your own values

Create and launch the workstation (docker container)
```
./workstation/launch.sh [--no-cache]
```

Deploy the layers
```
./infra-builder-terraform.sh --account <account_name> [--plan]

# or you can select a particular layer
./infra-builder-terraform.sh --account <account_name> --category <category_name> --layer <layer_name> [--plan]
```

Generate inventory
```
./infra-make-inventory.sh
```

Provision the infrastructure
```
./infra-provisioning.sh
```
