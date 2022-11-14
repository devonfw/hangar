import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_installation.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/ddesktop_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/rancher_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/unix_controller.dart';
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
    switch (await checkDockerInstallationType()) {
      case DockerInstallation.rancherDesktop:
        return RancherController();
      case DockerInstallation.dockerDesktop:
        return DockerDesktopController();
      case DockerInstallation.unix:
        return UnixController();
    }
  }

  /// Checks which installation type is in the system.
  ///
  /// The argument [systemService] is only for testing purposes
  @visibleForTesting
  Future<DockerInstallation> checkDockerInstallationType() async {
    if (platformService.isUnix) {
      return DockerInstallation.unix;
    }

    if (await systemService.isDockerDesktopInstalled()) {
      return DockerInstallation.dockerDesktop;
    }

    return DockerInstallation.rancherDesktop;
  }
}
