import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class RunCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "run";
  @override
  final String description =
      "Creates a shell with the selected project and the TakeOff service account";
  final CloudProviderId cloudProvider;

  RunCommand(this.service, this.cloudProvider) {
    argParser.addOption("project", mandatory: true);
  }

  @override
  void run() {
    service.runProject(argResults?["project"], cloudProvider);
  }
}
