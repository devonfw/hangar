#!/bin/bash
settings_path="$(pwd)/.pipelines/scripts/settings.xml"
mvn deploy --settings $settings_path