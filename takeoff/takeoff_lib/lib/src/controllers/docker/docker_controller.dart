import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/logger/log.dart';
import 'package:takeoff_lib/src/utils/system/system_service.dart';

/// Defines all Docker related operations, such as creating images, launching containers
/// and checking installation requirements.
abstract class DockerController {
  /// Reference to the FolderService singleton.
  ///
  /// Is instanced in the main DockerController file because it's used
  /// in all of the subclasses.
  final FoldersService foldersService = GetIt.I.get<FoldersService>();

  /// Service to make system calls
  final SystemService systemService;

  DockerController({SystemService? systemService})
      : systemService = systemService ?? SystemService();

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
    List<String> args = buildCommands(dockerArgs, commands);

    Process dockerProc = await Process.start("docker", args);
    stdout.addStream(dockerProc.stdout);
    stderr.addStream(dockerProc.stderr);

    Log.info("Executing ${Log.dockerProcessToString(args)}");

    if (await dockerProc.exitCode != 0) {
      Log.error("Exit code ${await dockerProc.exitCode}");
      Log.error("There was an unexpected error with the docker command");
      return false;
    }

    return true;
  }

  /// Builds the list of arguments for the "docker" command in [executeCommand]
  @visibleForTesting
  List<String> buildCommands(List<String> dockerArgs, List<String> commands) {
    List<String> volumeMappings = getVolumeMappings();

    return ["run", "--rm"] +
        dockerArgs +
        volumeMappings +
        [imageName] +
        commands;
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
    if (!systemService.isDockerInstalled()) {
      Log.error("Docker is not installed");
      return false;
    }
    if (!systemService.isDockerRunning()) {
      Log.error("Docker is not running");
      return false;
    }

    return true;
  }
}
