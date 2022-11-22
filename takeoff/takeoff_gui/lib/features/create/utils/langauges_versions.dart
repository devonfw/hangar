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
    Language.flutter: [
      "3.0.0",
      "3.0.5",
      "3.3.2",
      "3.3.4",
      "3.3.5",
      "3.3.6",
      "3.3.7"
    ],
    Language.angular: ["latest"],
    Language.python: ["3.9", "3.10", "3.11"],
    Language.node: ["latest"],
    Language.quarkus: ["latest"],
    Language.quarkusJVM: ["latest"],
    Language.none: ["Not available"],
  };
}
