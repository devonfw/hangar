import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class AzureCommand extends Command {
  final ProjectsService service;
  @override
  String get description => "Contains all commands related to Azure";

  @override
  String get name => "azure";

  AzureCommand(this.service);

  @override
  void run() {
    Log.warning("Azure is currently not supported");
  }
}
