import 'package:args/command_runner.dart';

class InitCommand extends Command {
  @override
  final name = "init";
  @override
  final description =
      "Initialize the account which will use the selecter cloud provider.";

  InitCommand() {
    // we can add command specific arguments here.
    // [argParser] is automatically created by the parent class.
    argParser.addOption('cloud',
        allowed: ["gc", "aws", "azure"], mandatory: true);
  }

  @override
  void run() {
    print("Testing run ${argResults!["cloud"]}");
  }
}
