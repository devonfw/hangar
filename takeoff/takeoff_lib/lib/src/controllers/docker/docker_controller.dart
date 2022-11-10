import 'dart:convert';
import 'dart:io';

import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/logger/log.dart';

/// Defines all Docker related operations, such as creating images, launching containers
/// and checking installation requirements.
abstract class DockerController {
  /// Launches a Hangar container with [dockerArgs] and mounted volumes executing
  /// the orders passed in [commands].
  /// This is only for commands that do not require user input such as 'ls'
  /// or executing a script.
  ///
  /// For interactive commands see [executeCommandInteractive].
  ///
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
    List<String> args =
        ["run", "--rm"] + dockerArgs + volumeMappings + ["hangar"] + commands;

    Process dockerProc = await Process.start("docker", args);
    stdout.addStream(dockerProc.stdout);
    stderr.addStream(dockerProc.stderr);

    Log.info("Executing ${_logProcess(args)}");

    if (await dockerProc.exitCode != 0) {
      Log.error("There was an unexpected error with the docker command");
      return false;
    }

    return true;
  }

  /// Launches an external terminal with a Hangar container with [dockerArgs] and
  /// mounted volumes executing the orders passed in [commands].
  /// This for commands that require user input such as 'bash'.
  ///
  /// For non-interactive commands see [executeCommand].
  ///
  ///
  /// For example, if we passed `["-d", "-p"]` as [dockerArgs] and `["bash"]` as [commands]
  /// it would generate:
  ///
  /// `docker run --rm -it -d -p [-v hostFolder:containerFolder] hangar bash`
  ///
  /// Returns whether the execution was succesful.
  Future<bool> executeCommandInteractive(
      List<String> dockerArgs, List<String> commands) async {
    List<String> volumeMappings = getVolumeMappings();
    List<String> args = ["run", "--rm", "-it"] +
        dockerArgs +
        volumeMappings +
        ["hangar"] +
        commands;

    //late ;

    Process interactiveProcess =
        await Process.start("docker", args, runInShell: true);

    Log.info("Executing ${_logProcess(args)} detached");

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

  /// Returns whether, after the execution of the method, we have a valid Hangar image available.
  Future<bool> prepareHangarImage() async {
    if (await _isHangarImageInstalled()) {
      Log.info("Hangar image is already installed");
      return true;
    }

    Log.info("Installing Hangar image...");

    return await _buildHangarImage();
  }

  /// Whether we already have a Hangar image installed.
  Future<bool> _isHangarImageInstalled() async {
    ProcessResult dockerProc =
        await Process.run("docker", ["image", "inspect", "hangar"]);
    return dockerProc.exitCode == 0;
  }

  /// Returns whether the process of building the Hangar image was succesful.
  ///
  /// First, it downloads the Dockerfile from the Hangar repo and then builds the image.
  Future<bool> _buildHangarImage() async {
    Directory cacheFolder = FoldersService.getCacheFolder();

    Log.info("Downloading Hangar Dockerfile...");
    Process downloadProc = await Process.start("curl", [
      "https://raw.githubusercontent.com/devonfw/hangar/master/setup/Dockerfile",
      "--output",
      "${cacheFolder.path}Dockerfile"
    ]);

    stdout.addStream(downloadProc.stdout);
    stderr.addStream(downloadProc.stderr);

    if (await downloadProc.exitCode != 0) {
      Log.error("Unexpected error downloading Dockerfile");
      return false;
    }

    Log.success("Dockerfile downloaded");
    Log.info("Creating Hangar image");

    Process dockerProc = await Process.start("docker", [
      "build",
      "-t",
      "hangar",
      "-f",
      "${cacheFolder.path}Dockerfile",
      cacheFolder.path
    ]);

    stdout.addStream(dockerProc.stdout);
    stderr.addStream(dockerProc.stderr);

    if (await dockerProc.exitCode != 0) {
      Log.error("Unexpected error creating Hangar image");
      return false;
    }

    Log.success("Hangar image created");

    return true;
  }

  String _logProcess(List<String> args) {
    return args.fold(
        "docker ", (previousValue, element) => "$previousValue $element");
  }
}
