#!/bin/bash
mvn package -B -Pnative

#installs xmlstarlet to add dependencies
apt-get install xmlstarlet