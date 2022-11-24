import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class QuickstartVipLaneCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "viplane";
  @override
  final String description =
      "Automatically creates and deploys all the necessary"
      " services and resources to have VipLane on the cloud.";

  QuickstartVipLaneCommand(this.service);

  @override
  void run() {
    Log.error("VipLane is not currently supported in quickstart");
  }
}
