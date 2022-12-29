flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter test --coverage
remove_from_coverage -f coverage/lcov.info -r '.g.dart$'
remove_from_coverage -f coverage/lcov.info -r '_libw.dart$'
remove_from_coverage -f coverage/lcov.info -r 'options.dart$'
remove_from_coverage -f coverage/lcov.info -r 'mock_projects.dart$'
