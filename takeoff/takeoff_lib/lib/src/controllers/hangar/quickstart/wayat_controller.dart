import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/hangar/quickstart/wayat_exception.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/quickstart/wayat_backend.dart';

class WayatController {
  Future<void> setUpWayat(WayatBackend script) async {
    DockerController controller = GetIt.I.get<DockerController>();

    if (!await controller.executeCommand([], script.toCommand())) {
      throw WayatException("Could not set up wayat");
    }
  }
}
