#!/bin/bash
set -e

flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs