import 'dart:io';

import 'package:takeoff_lib/src/controllers/auth/auth_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller_factory.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/domain/gcloud.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/utils/logger/log.dart';
import 'package:takeoff_lib/src/utils/url_launcher/url_launcher.dart';

/// Specific implementation of the authentication process for Google Cloud
class GCloudAuthController extends AuthController<GCloud> {
  @override
  Future<bool> authenticate(String email) async {
    DockerController dockerController = await DockerControllerFactory.create();

    List<String> volumeMappings = dockerController.getVolumeMappings();

    List<String> args = ["run", "--rm", "-i"] +
        volumeMappings +
        [DockerController.imageName] +
        ["gcloud", "auth", "login", email];

    var gcloudProcess = await Process.start("docker", args, runInShell: true);

    Log.info("Opening Google Authentication in the browser");
    bool openedUrl = false;

    var stderrHandler = gcloudProcess.stderr.listen((event) async {
      String message = String.fromCharCodes(event).trim();
      if (!openedUrl && !message.startsWith("WARNING")) {
        String url = message.split("\n").last.trim();
        if (Uri.tryParse(url) != null) {
          UrlLaucher.launch(url);
        }
        openedUrl = true;
      } else {
        stdout.writeln(message);
      }
    });

    var stdoutHandler = gcloudProcess.stdout.listen((event) {
      stdout.writeln(String.fromCharCodes(event));
    });

    var stdinHandler = stdin.listen((event) {
      gcloudProcess.stdin.writeln(String.fromCharCodes(event).trim());
    });

    int exitCode = await gcloudProcess.exitCode;

    stderrHandler.cancel();
    stdinHandler.cancel();
    stdoutHandler.cancel();

    if (exitCode != 0) {
      Log.error("Could not login in Google Cloud");
      return false;
    }

    Log.info("Login succesful with $email");
    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.saveGoogleEmail(email);

    return true;
  }
}
