import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/hangar/project/project_controller.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/project/create_project.dart';

/// Project controller for Google Cloud.
class ProjectControllerGCloud implements ProjectController {
  final CreateProjectGCloud createScript;

  ProjectControllerGCloud(this.createScript);

  @override
  Future<bool> createProject() async {
    DockerController controller = GetIt.I.get<DockerController>();

    if (!await controller.executeCommand([], createScript.toCommand())) {
      return false;
    }

    return true;
  }
}
