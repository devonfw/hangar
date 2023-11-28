#!/bin/bash
mvn package -B

mvn test -B -Dmaven.install.skip=true