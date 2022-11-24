import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/auth/auth_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller_factory.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/domain/gcloud.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/utils/logger/log.dart';
import 'package:takeoff_lib/src/utils/url_launcher/url_launcher.dart';

/// Specific implementation of the authentication process for Google Cloud
class GCloudAuthController implements AuthController<GCloud> {
  Stream<List<int>>? stdinStream;

  GCloudAuthController({this.stdinStream});

  @override
  Future<bool> authenticate(
    String email,
  ) async {
    DockerController dockerController = GetIt.I.get<DockerController>();

    List<String> volumeMappings = dockerController.getVolumeMappings();

    List<String> args = ["run", "--rm", "-i"] +
        volumeMappings +
        [DockerController.imageName] +
        ["gcloud", "auth", "login", email];

    Log.info("Authenticating with Google Cloud");
    Log.info("Launching ${dockerController.command} + $args");
    Process gCloudProcess =
        await Process.start(dockerController.command, args, runInShell: true);

    bool openedUrl = false;

    StreamSubscription<List<int>> stderrHandler =
        gCloudProcess.stderr.listen((event) async {
      String message = String.fromCharCodes(event).trim();
      if (!openedUrl && !message.startsWith("WARNING")) {
        String url = message.split("\n").last.trim();
        if (Uri.tryParse(url) != null) {
          Log.info("Opening Google Authentication in the browser");
          UrlLaucher.launch(url);
        }
        openedUrl = true;
      } else {
        stdout.writeln(message);
      }
    });

    StreamSubscription<List<int>> stdoutHandler =
        gCloudProcess.stdout.listen((event) {
      stdout.writeln(String.fromCharCodes(event));
    });

    late StreamSubscription<List<int>> stdinHandler;

    if (stdinStream != null) {
      stdinHandler = stdinStream!.listen((event) {
        gCloudProcess.stdin.writeln(String.fromCharCodes(event).trim());
      });
    } else {
      stdinHandler = stdin.listen((event) {
        gCloudProcess.stdin.writeln(String.fromCharCodes(event).trim());
      });
    }

    int exitCode = await gCloudProcess.exitCode;

    stderrHandler.cancel();
    stdinHandler.cancel();
    stdoutHandler.cancel();

    if (exitCode != 0) {
      Log.error(
          "The hangar docker process exited with an exit code of $exitCode");
      return false;
    }

    Log.info("Login succesful with $email");
    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.saveGoogleEmail(email);

    return true;
  }

  @override
  Future<String> getCurrentAccount() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    return await cacheRepository.getGoogleEmail();
  }

  @override
  Future<bool> logOut() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    return await cacheRepository.removeGoogleEmail();
  }
}
