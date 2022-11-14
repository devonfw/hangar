import 'dart:io';

import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_installation.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/ddesktop_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/rancher_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/unix_controller.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';

/// Factory for the Docker controller.
///
/// Returns the appropiate instance of the Docker Controller depending on platform
/// and the current docker installation.
///
/// The options are [RancherController], [DockerDesktopController] and [UnixController].
class DockerControllerFactory {
  /// Returns the appropiate [DockerController] instance.
  static Future<DockerController> create() async {
    switch (await _checkDockerInstallationType()) {
      case DockerInstallation.rancherDesktop:
        return RancherController();
      case DockerInstallation.dockerDesktop:
        return DockerDesktopController();
      case DockerInstallation.unix:
        return UnixController();
    }
  }

  /// Checks which installation type is in the system.
  static Future<DockerInstallation> _checkDockerInstallationType() async {
    if (PlatformService.isUnix) {
      return DockerInstallation.unix;
    }

    ProcessResult taskChecker = await Process.run(
        "tasklist", ["|", "find", "/i", "Docker Desktop.exe"],
        stdoutEncoding: SystemEncoding(), runInShell: true);

    if ((taskChecker.stdout as String).isNotEmpty) {
      return DockerInstallation.dockerDesktop;
    }

    return DockerInstallation.rancherDesktop;
  }
}
