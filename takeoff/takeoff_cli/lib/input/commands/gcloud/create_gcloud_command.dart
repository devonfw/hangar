import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class CreateGCloudCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "create";
  @override
  final String description =
      "Creates a new project in the specified cloud provider and sets up the environment";

  CreateGCloudCommand(this.service) {
    argParser.addOption('name', abbr: 'n', mandatory: true);
    argParser.addOption('billing-account', abbr: 'a', mandatory: true);
    argParser.addOption('backend-language',
        abbr: 'b',
        allowed: [
          Language.node.name,
          Language.python.name,
          Language.quarkus.name,
          Language.quarkusJVM.name,
        ],
        help:
            "The technology for the BackEnd. Required if no frontend-language is specified.");
    argParser.addOption("backend-version",
        help:
            "The version for the backend-language. This will have no effect unless backend-language is specified.");
    argParser.addOption('frontend-language',
        abbr: 'f',
        allowed: [
          Language.angular.name,
          Language.flutter.name,
        ],
        help:
            "The technology for the FrontEnd. Required if no backend-language is specified.");
    argParser.addOption("frontend-version",
        help:
            "The version for the frontend-language. This will have no effect unless frontend-language is specified.");
    argParser.addOption('region',
        abbr: 'r',
        mandatory: true,
        help: "Google Cloud region in which the project will be created.");
  }

  @override
  void run() {
    service.createGoogleProject(
        projectName: argResults?["name"],
        billingAccount: argResults?["billing-account"],
        backendLanguage: Language.fromString(argResults?["backend-language"]),
        backendVersion: argResults?["backend-version"],
        frontendLanguage: Language.fromString(argResults?["frontend-language"]),
        frontendVersion: argResults?["frontend-version"],
        googleCloudRegion: argResults?["region"]);
  }
}
