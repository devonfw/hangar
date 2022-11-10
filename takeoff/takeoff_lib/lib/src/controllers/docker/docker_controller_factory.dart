import 'dart:io';

import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_installation.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/ddesktop_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/rancher_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/unix_controller.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';

class DockerControllerFactory {
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
