import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/quickstart/wayat_exception.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/quickstart/wayat_script.dart';

class WayatController {
  Future<void> setUpWayat(WayatScript script) async {
    DockerController controller = GetIt.I.get<DockerController>();

    if (!await controller.executeCommand([], script.toCommand())) {
      throw WayatException("Could not set up wayat");
    }
  }
}
