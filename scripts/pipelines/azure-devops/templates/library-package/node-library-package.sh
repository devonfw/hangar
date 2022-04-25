#!/bin/bash
npmrc_path="$(pwd)/.pipelines/scripts/.npmrc"
npm publish --userconfig "$npmrc_path"