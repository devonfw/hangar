import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';

class CleanCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "clean";
  @override
  final String description =
      "Removes all the local data of the provided project. This will not delete"
      " the project in the cloud provider.";

  CleanCommand(this.service) {
    argParser.addOption('cloud',
        allowed: ["gc", "aws", "azure"], mandatory: true);
    argParser.addOption('id', mandatory: true);
  }

  @override
  void run() {
    service.cleanProject(argResults?["cloud"], argResults?["id"]);
  }
}
