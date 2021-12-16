#!/bin/bash

#The terraform init command will initialize the working directory containing Terraform configuration files and install any required plugins.
terraform init
#he terraform apply command performs a plan and actually carries out the planned changes to each resource using the relevant infrastructure provider's API.
terraform apply --auto-approve
