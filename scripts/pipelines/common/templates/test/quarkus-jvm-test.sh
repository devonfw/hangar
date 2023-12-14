#!/bin/bash
mvn test -B -Dmaven.install.skip=true -Djacoco.append=true -Dmaven.test.failure.ignore=true
