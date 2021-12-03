#!/bin/bash

variable="./terraform.tfvars"
    
list_of_args=$@
echo "list: '$list_of_args'"
for arg in $list_of_args
do
value=$(echo $arg | cut -d'=' -f2)
parameter=$(echo $arg | cut -d'=' -f1)
echo "$parameter = \"$value\"" >> "$variable"
done

terraform init
terraform apply --auto-approve