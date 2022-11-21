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
    argParser.addOption('frontend_language',
        abbr: 'f',
        allowed: [
          Language.angular.name,
          Language.flutter.name,
        ],
        mandatory: true);
    argParser.addOption('region', abbr: 'r', mandatory: true);
  }

  @override
  void run() {
    service.createGoogleProject(
        argResults?["name"],
        argResults?["billing_account"],
        Language.fromString(argResults?["backend_language"]),
        Language.fromString(argResults?["frontend_language"]),
        argResults?["region"]);
  }
}
