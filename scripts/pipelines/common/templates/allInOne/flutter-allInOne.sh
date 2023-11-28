#!/bin/bash
set -e

flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter test

# Quality
projectKey=$(grep -m 1 name pubspec.yaml | tr -s ' ' | tr -d ':' | cut -d' ' -f2 | tr -d '\n' | tr -d '\r')
sonar-scanner -Dsonar.host.url="$SONAR_URL" -Dsonar.login="$SONAR_TOKEN" -Dsonar.projectKey="$projectKey" -Dsonar.sources="lib" -Dsonar.exclusions=test/**/*_test.mocks.dart,lib/**/*.g.dart,lib/**/*.gr.dart,lib/**/*.freezed.dart -Dsonar.tests=test -Dsonar.sourceEncoding=UTF-8