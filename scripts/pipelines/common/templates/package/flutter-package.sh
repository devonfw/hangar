#!/bin/bash
export tag=$(grep -m 1 version pubspec.yaml | tr -s ' ' | tr -d ':' | cut -d' ' -f2 | cut -d'+' -f1)