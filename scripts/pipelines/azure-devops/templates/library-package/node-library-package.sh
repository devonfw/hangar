#!/bin/bash
npmrc_path="$(pwd)/.pipelines/scripts/.npmrc"
npm --userconfig $npmrc_path publish