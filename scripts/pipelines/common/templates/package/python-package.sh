#!/bin/bash
# We define the tag using the version set in the pyproject.toml
imageTagFilePath="pyproject.toml"
export tag=$(grep -m 1 version "${imageTagFilePath}" | tr -s ' ' | tr -d '"' | tr -d "'" | cut -d' ' -f3)