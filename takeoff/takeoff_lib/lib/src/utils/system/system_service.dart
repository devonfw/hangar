import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';

class SystemService {
  FoldersService foldersService = GetIt.I.get<FoldersService>();

  /// Checks that all the necessary requirements for TakeOff to run are met.
  ///
  /// These are that there is a valid Docker installation and the cache folders are created.
  Future<bool> checkSystemPrerequisites() async {
    if (!GetIt.I.get<DockerController>().checkDockerInstallation()) {
      return false;
    }
    if (!foldersService.createHostFolders()) return false;

    return true;
  }

  /// Whether Docker Desktop is installed
  Future<bool> isDockerDesktopInstalled() async {
    assert(GetIt.I.get<PlatformService>().isWindows);

    ProcessResult taskChecker = await Process.run(
        "tasklist", ["|", "find", "/i", "Docker Desktop.exe"],
        stdoutEncoding: SystemEncoding(), runInShell: true);

    return (taskChecker.stdout as String).isNotEmpty;
  }

  /// Whether the Docker daemon is running
  bool isDockerRunning() {
    ProcessResult dockerProc = Process.runSync("docker", ["ps"]);
    return dockerProc.exitCode == 0;
  }

  /// Whether Docker is installed.
  bool isDockerInstalled() {
    late ProcessResult dockerProc;
    try {
      dockerProc = Process.runSync("docker", ["-v"]);
    } on ProcessException {
      return false;
    }
    return dockerProc.exitCode == 0;
  }
}
