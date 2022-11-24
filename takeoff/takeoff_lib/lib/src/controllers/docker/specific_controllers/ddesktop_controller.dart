import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/system/system_service.dart';

/// [DockerController] implementation for Windows systems with Docker Desktop.
class DockerDesktopController extends DockerController {
  DockerDesktopController({SystemService? systemService})
      : super(command: "docker", systemService: systemService);

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
