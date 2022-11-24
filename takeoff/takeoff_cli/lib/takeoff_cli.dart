import 'package:args/command_runner.dart';
import 'package:takeoff_cli/input/commands/aws/aws_command.dart';
import 'package:takeoff_cli/input/commands/azure/azure_command.dart';
import 'package:takeoff_cli/input/commands/gcloud/gcloud_command.dart';
import 'package:takeoff_cli/input/commands/quickstart/quickstart_command.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class TakeOffCli {
  void run(List<String> args) async {
    TakeOffFacade facade = TakeOffFacade();
    await facade.initialize();

    ProjectsService projectsService = ProjectsService(facade);
    CommandRunner("takeoff", "A CLI to easily create a new cloud environment.")
      ..addCommand(QuickstartCommand(projectsService))
      ..addCommand(GCloudCommand(projectsService))
      ..addCommand(AwsCommand(projectsService))
      ..addCommand(AzureCommand(projectsService))
      ..run(args);
  }
}
