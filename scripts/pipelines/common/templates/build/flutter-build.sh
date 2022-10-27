#!/bin/bash
set -e

flutter pub clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs