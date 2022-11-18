import 'package:args/command_runner.dart';
import 'package:takeoff_cli/input/commands/gcloud_command.dart';
import 'package:takeoff_cli/input/commands/init_command.dart';
import 'package:takeoff_cli/input/commands/list_command.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class TakeOffCli {
  void run(List<String> args) async {
    TakeOffFacade facade = TakeOffFacade();
    await facade.initialize();

    ProjectsService projectsService = ProjectsService(facade);
    CommandRunner("takeoff", "A CLI to easily create cloud environment.")
      ..addCommand(InitCommand(projectsService))
      ..addCommand(ListCommand(projectsService))
      ..addCommand(GCloudCommand(projectsService))
      ..run(args);
  }
}
