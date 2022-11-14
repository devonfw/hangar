import 'package:args/command_runner.dart';
import 'package:takeoff_cli/input/commands/init_command.dart';

class TakeOffCli {
  void run(List<String> args) {
    CommandRunner("takeoff", "A CLI to easily create cloud environment.")
      ..addCommand(InitCommand())
      ..run(args);
  }
}
