import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/hangar/repository/repository_controller.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/repo/create_repo.dart';

class RepositoryControllerGCloud
    implements RepositoryController<CreateRepoGCloud> {
  @override
  Future<bool> createRepository(CreateRepoGCloud script) async {
    DockerController controller = GetIt.I.get<DockerController>();
    if (!await controller.executeCommand([], script.toCommand())) {
      return false;
    }

    return true;
  }
}
