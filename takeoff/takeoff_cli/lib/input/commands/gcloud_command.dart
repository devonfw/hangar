import 'package:args/command_runner.dart';
import 'package:takeoff_cli/input/commands/create_gcloud_command.dart';
import 'package:takeoff_cli/services/project_service.dart';

class GCloudCommand extends Command {
  final ProjectsService service;
  @override
  String get description => "Contains all commands related to Google Cloud";

  @override
  String get name => "gc";

  GCloudCommand(this.service) {
    addSubcommand(CreateGCloudCommand(service));
  }
}
