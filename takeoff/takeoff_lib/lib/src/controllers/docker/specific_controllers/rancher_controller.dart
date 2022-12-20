import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/system/system_service.dart';

/// [DockerController] implementation for Windows systems with Rancher Desktop.
class RancherController extends DockerController {
  RancherController({required String command, SystemService? systemService})
      : super(command: command, systemService: systemService);

  @override
  List<String> getVolumeMappings() {
    Map<String, String> hostFolders = foldersService.getHostFolders();
    String preprend = (command == "docker") ? "/mnt/c" : "";

    hostFolders = hostFolders.map((name, path) =>
        MapEntry(name, "$preprend${path.replaceAll("\\", "/").substring(2)}"));

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
