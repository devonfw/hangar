import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/quickstart/cloud_run_exception.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/quickstart/init_cloud_run.dart';

class CloudRunController {
  Future<void> initCloudRun(InitCloudRun script) async {
    DockerController controller = GetIt.I.get<DockerController>();

    if (!await controller.executeCommand([], script.toCommand())) {
      throw CloudRunException("Could not set up Cloud Run for ${script.name}");
    }
  }
}
