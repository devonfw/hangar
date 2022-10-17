#!/bin/bash
npmrc_path="$(pwd)/.pipelines/scripts"
cp "${npmrc_path}/.npmrc.project.template" "$(pwd)/.npmrc"
npm publish --userconfig "${npmrc_path}/.npmrc"