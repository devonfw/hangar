import 'package:takeoff_lib/src/controllers/auth/gcloud_auth_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller_factory.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';

class TakeOffFacade {
  Future<bool> checkEnvironment() async {
    DockerController dockerController = await DockerControllerFactory.create();
    if (!dockerController.checkDockerInstallation()) return false;

    await dockerController.prepareHangarImage();

    if (!FoldersService.createHostFolders()) return false;

    GCloudAuthController gCloudAuthController = GCloudAuthController();
    await gCloudAuthController.authenticate("email");

    return true;
  }
}
