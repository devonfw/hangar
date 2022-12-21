import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class ListCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "list";
  @override
  final String description =
      "List all the projects created from TakeOff with the selected Cloud Provider";
  final CloudProviderId cloudProvider;

  ListCommand(this.service, this.cloudProvider);

  @override
  void run() {
    service.listProjects(cloudProvider);
  }
}
