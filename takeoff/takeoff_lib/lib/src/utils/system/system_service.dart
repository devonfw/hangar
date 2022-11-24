import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_installation.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/logger/log.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';

class SystemService {
  FoldersService foldersService = GetIt.I.get<FoldersService>();

  /// Checks that all the necessary requirements for TakeOff to run are met.
  ///
  /// These are that there is a valid Docker installation and the cache folders are created.
  Future<bool> checkSystemPrerequisites() async {
    DockerCommand command = checkDockerCommand();
    switch (command) {
      case DockerCommand.none:
        Log.error("Neither docker nor nerdctl are running");
        return false;
      default:
        GetIt.I.get<DockerType>().command = command;
        break;
    }
    if (!foldersService.createHostFolders()) {
      Log.error("Could not create host folders");
      return false;
    }

    return true;
  }

  /// Whether Docker is installed and running.
  ///
  /// Both of this conditions are prerequisites for TakeOff to run.
  DockerCommand checkDockerCommand() {
    if (isNerdctlRunning()) {
      return DockerCommand.nerdctl;
    }
    if (isDockerRunning()) {
      return DockerCommand.docker;
    }

    return DockerCommand.none;
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
    try {
      ProcessResult dockerProc = Process.runSync("docker", ["ps"]);
      return dockerProc.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }

  /// Whether the Docker daemon is running
  bool isNerdctlRunning() {
    try {
      ProcessResult dockerProc = Process.runSync("nerdctl", ["ps"]);
      return dockerProc.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }
}
