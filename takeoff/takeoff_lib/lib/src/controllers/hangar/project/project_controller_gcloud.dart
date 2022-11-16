import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/hangar/project/project_controller.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/account/create_project.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';

class ProjectControllerGCloud implements ProjectController {
  final CreateProjectGCloud createScript;

  ProjectControllerGCloud(this.createScript);

  @override
  Future<bool> createProject() async {
    DockerController controller = GetIt.I.get<DockerController>();

    if (!await controller.executeCommand([], createScript.toCommand())) {
      return false;
    }

    CacheRepository cacheRepository = CacheRepositoryImpl();

    await cacheRepository.saveGoogleProjectId(createScript.projectName);

    return true;
  }
}
