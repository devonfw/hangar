import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/system/system_service.dart';

/// [DockerController] implementation for Unix systems, that do not need
/// Rancher Desktop nor Docker Desktop.
class UnixController extends DockerController {
  UnixController({required String command, SystemService? systemService})
      : super(command: command, systemService: systemService);

  @override
  List<String> getVolumeMappings() {
    Map<String, String> hostFolders = foldersService.getHostFolders();
    Map<String, String> containerFolders = FoldersService.containerFolders;

    List<String> volumeMappings = hostFolders.entries
        .map((hostFolder) =>
            "${hostFolder.value}:${containerFolders[hostFolder.key]}")
        .toList();

    for (int i = 0; i < volumeMappings.length; i += 2) {
      volumeMappings.insert(i, "-v");
    }
    return volumeMappings;
  }
}
