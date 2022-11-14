import 'dart:io';

import 'package:takeoff_lib/src/utils/logger/log.dart';

/// Defines all Docker related operations, such as creating images, launching containers
/// and checking installation requirements.
abstract class DockerController {
  static String imageName = "hangar";

  /// Launches a Hangar container with [dockerArgs] and mounted volumes executing
  /// the orders passed in [commands].
  ///
  /// For example, if we passed `["-d", "-p"]` as [dockerArgs] and `["ls"]` as [commands]
  /// it would generate:
  ///
  /// `docker run --rm -d -p [-v hostFolder:containerFolder] hangar ls`
  ///
  /// Returns whether the execution was succesful.
  Future<bool> executeCommand(
      List<String> dockerArgs, List<String> commands) async {
    List<String> volumeMappings = getVolumeMappings();

    commands.insert(0, imageName);
    commands.insertAll(0, volumeMappings);
    commands.insertAll(0, dockerArgs);
    commands.insertAll(0, ["run", "--rm"]);

    Process dockerProc = await Process.start("docker", commands);
    stdout.addStream(dockerProc.stdout);
    stderr.addStream(dockerProc.stderr);

    Log.info("Executing ${Log.dockerProcessToString(commands)}");

    if (await dockerProc.exitCode != 0) {
      Log.error("There was an unexpected error with the docker command");
      return false;
    }

    return true;
  }

  /// Returns the list of the volume mappings for the Hangar container.
  ///
  /// Because the containers are stateless, we need to mount volumes in each run
  /// to have persistence in the Cloud CLIs for things like authentication.
  ///
  /// It needs to be overwritten because of variances in folder paths of Docker
  /// installations and platform.
  ///
  /// It will generate a list like the following:
  ///
  /// `["-v", "hostFolder:containerFolder", "-v", "hostFolder2:ContainerFolder2"]`
  List<String> getVolumeMappings();

  /// Whether Docker is installed and running.
  ///
  /// Both of this conditions are prerequisites for TakeOff to run.
  bool checkDockerInstallation() {
    if (!_isDockerInstalled()) {
      Log.error("Docker is not installed");
      return false;
    }
    if (!_isDockerRunning()) {
      Log.error("Docker is not running");
      return false;
    }

    return true;
  }

  /// Whether the Docker daemon is running
  bool _isDockerRunning() {
    ProcessResult dockerProc = Process.runSync("docker", ["ps"]);
    return dockerProc.exitCode == 0;
  }

  /// Whether Docker is installed.
  bool _isDockerInstalled() {
    late ProcessResult dockerProc;
    try {
      dockerProc = Process.runSync("docker", ["-v"]);
    } on ProcessException {
      return false;
    }
    return dockerProc.exitCode == 0;
  }
}
