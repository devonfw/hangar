#!/bin/bash
mvn package -B -Pnative

mvn test -B -Dmaven.install.skip=true -Pnative