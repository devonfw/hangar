import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/hangar_scripts/common/terraform/setup_sonar.dart';

class SonarqubeController {
  Future<bool> execute(SetUpSonar script) async {
    DockerController controller = GetIt.I.get<DockerController>();

    if (!await controller.executeCommand([], script.toCommand())) {
      return false;
    }

    return true;
  }
}
