import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';

class ListCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "list";
  @override
  final String description =
      "List all the projects created from TakeOff with the selected Cloud Provider";

  ListCommand(this.service) {
    argParser.addOption("cloud",
        allowed: ["gc", "aws", "azure"], mandatory: true);
  }

  @override
  void run() {
    service.listProjects(argResults?["cloud"]);
  }
}
