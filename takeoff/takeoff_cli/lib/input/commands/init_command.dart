import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';

class InitCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "init";
  @override
  final String description =
      "Initialize the account which will use the selected cloud provider.";

  InitCommand(this.service) {
    argParser.addOption('cloud',
        allowed: ["gc", "aws", "azure"], mandatory: true);
    argParser.addOption('account', mandatory: true);
  }

  @override
  void run() {
    service.initAccount(argResults?["cloud"], argResults?["account"]);
  }
}
