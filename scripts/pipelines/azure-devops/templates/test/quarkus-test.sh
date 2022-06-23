#!/bin/bash
mvn --quiet test -B -Dmaven.install.skip=true -Pnative 
