#!/bin/bash
settings_path="$(pwd)/.pipelines/scripts/settings.xml"
mvn deploy -B -Dmaven.install.skip=true -Dmaven.test.skip=true --settings $settings_path