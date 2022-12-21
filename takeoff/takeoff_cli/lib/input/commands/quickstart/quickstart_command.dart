import 'package:args/command_runner.dart';
import 'package:takeoff_cli/input/commands/quickstart/quickstart_viplane_command.dart';
import 'package:takeoff_cli/input/commands/quickstart/quickstart_wayat_command.dart';
import 'package:takeoff_cli/services/project_service.dart';

class QuickstartCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "quickstart";
  @override
  final String description =
      "Automatically creates and deploys all the necessary"
      " services and resources to have either Wayat or VipLane on the cloud.";

  QuickstartCommand(this.service) {
    addSubcommand(QuickstartWayatCommand(service));
    addSubcommand(QuickstartVipLaneCommand(service));
  }
}
