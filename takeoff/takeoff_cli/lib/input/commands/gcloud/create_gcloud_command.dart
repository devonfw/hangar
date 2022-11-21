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
    argParser.addOption('billing_account', abbr: 'a', mandatory: true);
    argParser.addOption('backend_language',
        abbr: 'b',
        allowed: [
          Language.node.name,
          Language.python.name,
          Language.quarkus.name,
          Language.quarkusJVM.name
        ],
        mandatory: true);
    argParser.addOption("backend_version");
    argParser.addOption('frontend_language',
        abbr: 'f',
        allowed: [
          Language.angular.name,
          Language.flutter.name,
        ],
        mandatory: true);
    argParser.addOption("frontend_version");
    argParser.addOption('region', abbr: 'r', mandatory: true);
  }

  @override
  void run() {
    service.createGoogleProject(
        projectName: argResults?["name"],
        billingAccount: argResults?["billing_account"],
        backendLanguage: Language.fromString(argResults?["backend_language"]),
        backendVersion: argResults?["backend_version"],
        frontendLanguage: Language.fromString(argResults?["frontend_language"]),
        frontendVersion: argResults?["frontend_version"],
        googleCloudRegion: argResults?["region"]);
  }
}
