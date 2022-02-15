#!/bin/bash
settings_path="$(pwd)/.pipelines/scripts/settings.xml"
mvn deploy -Dmaven.test.skip=true --settings $settings_path