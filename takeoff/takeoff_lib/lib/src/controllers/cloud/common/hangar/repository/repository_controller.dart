import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/common/repo/create_repo.dart';

/// Controller for the repository operations in every provider.
class RepositoryController<T extends CreateRepo> {
  /// Creates a repository using the passed script in any cloud provider.
  Future<bool> createRepository(T script) async {
    DockerController controller = GetIt.I.get<DockerController>();
    if (!await controller.executeCommand([], script.toCommand())) {
      return false;
    }

    return true;
  }
}
