import 'package:takeoff_lib/takeoff_lib.dart';

class LanguagesVersions {
  static List<Language> frontendLanguages = [
    Language.flutter,
    Language.angular,
    Language.none,
  ];

  static List<Language> backendLanguages = [
    Language.python,
    Language.node,
    Language.quarkus,
    Language.quarkusJVM,
    Language.none,
  ];

  static Map<Language, List<String>> versionsLanguages = {
    Language.flutter: ["3.0", "3.1", "3.3"],
    Language.angular: ["5.1", "5.2", "5.3"],
    Language.python: ["2.7", "3.10", "3.11"],
    Language.node: ["8.3", "8.5"],
    Language.quarkus: ["1"],
    Language.quarkusJVM: ["1", "2"],
    Language.none: ["Not available"],
  };
}
