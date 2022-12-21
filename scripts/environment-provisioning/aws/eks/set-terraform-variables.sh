#!/bin/bash
file="./terraform.tfvars"
../../../set-config.sh --file_set_vars $file "${@}"
