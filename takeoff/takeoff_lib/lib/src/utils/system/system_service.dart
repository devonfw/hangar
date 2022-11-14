import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';

class SystemService {
  /// Checks that all the necessary requirements for TakeOff to run are met.
  ///
  /// These are that there is a valid Docker installation and the cache folders are created.
  static Future<bool> checkSystemPrerequisites() async {
    if (!GetIt.I.get<DockerController>().checkDockerInstallation()) {
      return false;
    }
    if (!FoldersService.createHostFolders()) return false;

    return true;
  }
}
