import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class AwsCommand extends Command {
  final ProjectsService service;
  @override
  String get description =>
      "Contains all commands related to Amazon Web Services";

  @override
  String get name => "aws";

  AwsCommand(this.service);

  @override
  void run() {
    Log.warning("AWS is currently not supported");
  }
}
