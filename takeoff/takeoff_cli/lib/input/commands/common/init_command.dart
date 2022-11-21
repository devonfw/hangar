import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class InitCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "init";
  @override
  final String description =
      "Initialize the account which will use the selected cloud provider.";
  final CloudProviderId cloudProvider;

  InitCommand(this.service, this.cloudProvider) {
    argParser.addOption('account', mandatory: true);
  }

  @override
  void run() {
    service.initAccount(cloudProvider, argResults?["account"]);
  }
}
