import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class QuickstartWayatCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "wayat";
  @override
  final String description =
      "Automatically creates and deploys all the necessary"
      " services and resources to have Wayat on the cloud.";

  QuickstartWayatCommand(this.service) {
    argParser.addOption("billing-account", abbr: "b", mandatory: true);
    argParser.addOption("google-cloud-region",
        abbr: "r", mandatory: true, allowed: firebaseRegions);
  }

  @override
  void run() {
    service.quickstartWayat(
        billingAccount: argResults?["billing-account"],
        googleCloudRegion: argResults?["google-cloud-region"]);
  }
}
