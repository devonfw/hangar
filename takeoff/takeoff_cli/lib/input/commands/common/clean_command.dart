import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class CleanCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "clean";
  @override
  final String description =
      "Removes all the local data of the provided project. This will not delete"
      " the project in the cloud provider.";
  final CloudProviderId cloudProvider;

  CleanCommand(this.service, this.cloudProvider) {
    argParser.addOption('id', mandatory: true);
  }

  @override
  void run() {
    service.cleanProject(cloudProvider, argResults?["id"]);
  }
}
