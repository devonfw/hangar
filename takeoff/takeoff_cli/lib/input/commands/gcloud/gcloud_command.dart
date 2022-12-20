import 'package:args/command_runner.dart';
import 'package:takeoff_cli/input/commands/common/clean_command.dart';
import 'package:takeoff_cli/input/commands/common/init_command.dart';
import 'package:takeoff_cli/input/commands/common/list_command.dart';
import 'package:takeoff_cli/input/commands/common/run_command.dart';
import 'package:takeoff_cli/input/commands/gcloud/create_gcloud_command.dart';
import 'package:takeoff_cli/input/commands/gcloud/open_gcloud_command.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class GCloudCommand extends Command {
  final ProjectsService service;
  @override
  String get description => "Contains all commands related to Google Cloud";

  @override
  String get name => "gc";

  GCloudCommand(this.service) {
    addSubcommand(CreateGCloudCommand(service));
    addSubcommand(CleanCommand(service, CloudProviderId.gcloud));
    addSubcommand(ListCommand(service, CloudProviderId.gcloud));
    addSubcommand(InitCommand(service, CloudProviderId.gcloud));
    addSubcommand(RunCommand(service, CloudProviderId.gcloud));
    addSubcommand(OpenGCloudCommand(service, CloudProviderId.gcloud));
  }
}
