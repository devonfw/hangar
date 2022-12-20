import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_installation.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/ddesktop_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/rancher_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/unix_controller.dart';
import 'package:takeoff_lib/src/utils/logger/log.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:takeoff_lib/src/utils/system/system_service.dart';

/// Factory for the Docker controller.
///
/// Returns the appropiate instance of the Docker Controller depending on platform
/// and the current docker installation.
///
/// The options are [RancherController], [DockerDesktopController] and [UnixController].
class DockerControllerFactory {
  final PlatformService platformService = GetIt.I.get<PlatformService>();
  final SystemService systemService;

  DockerControllerFactory({SystemService? systemService})
      : systemService = systemService ?? SystemService();

  /// Returns the appropiate [DockerController] instance.
  Future<DockerController> create() async {
    DockerType dockerType = await checkDockerInstallationType();
    switch (dockerType.installation) {
      case DockerInstallation.rancherDesktop:
        Log.info("Rancher desktop with ${dockerType.command.name}");
        return RancherController(command: dockerType.command.name);
      case DockerInstallation.dockerDesktop:
        Log.info("Docker desktop with ${dockerType.command.name}");
        return DockerDesktopController();
      case DockerInstallation.unix:
        Log.info("Unix system with ${dockerType.command.name}");
        return UnixController(command: dockerType.command.name);
      case DockerInstallation.unknown:
        throw UnsupportedError(
            "TakeOff could not determine the docker installation");
    }
  }

  /// Checks which installation type is in the system.
  ///
  /// The argument [systemService] is only for testing purposes
  @visibleForTesting
  Future<DockerType> checkDockerInstallationType() async {
    DockerType dockerType = GetIt.I.get<DockerType>();

    if (platformService.isUnix) {
      dockerType.installation = DockerInstallation.unix;
    } else if (await systemService.isDockerDesktopInstalled()) {
      dockerType.installation = DockerInstallation.dockerDesktop;
    } else {
      dockerType.installation = DockerInstallation.rancherDesktop;
    }

    return dockerType;
  }
}
