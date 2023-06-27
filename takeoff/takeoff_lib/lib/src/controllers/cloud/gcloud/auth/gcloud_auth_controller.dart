import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/auth/auth_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/domain/gcloud.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/utils/logger/log.dart';
import 'package:takeoff_lib/src/utils/url_launcher/url_launcher.dart';

/// Specific implementation of the authentication process for Google Cloud
///
/// When [stdinStream] is not null, it will use the data from that stream to
/// pass it as the Google Cloud token.
///
/// If [useStdin] is true, it will read a line from the standard input to
/// pass it as the Google Cloud token,
///
/// If [useStdin] is `false` and [stdinStream] is `null`, that means that you
/// expect that the user is already authenticated and that Google Cloud has
/// to reuse the credentials. This is, for example, in the beginning of the
/// `createProject`, `quickstartWayat` or `run` processes, when you need to
/// make sure that the account used is the user's and not a previously
/// set service account. This arguments will not work to log in, only to
/// set the CLI to the logged account.
///
/// [useStdin] cannot be `true` if [stdinStream] is not `null`.
class GCloudAuthController implements AuthController<GCloud> {
  Stream<List<int>>? stdinStream;
  bool useStdin;

  GCloudAuthController({this.useStdin = false, this.stdinStream}) {
    assert((useStdin && stdinStream == null) || (!useStdin));
  }

  @override
  Future<bool> authenticate(String email) async {
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
          await UrlLaucher().launch(url);
          if (useStdin) {
            String? line = stdin.readLineSync();
            gCloudProcess.stdin.writeln(line?.trim());
          }
        }
        openedUrl = true;
      } else {
        stdout.writeln(message);
      }
    });

    StreamSubscription<List<int>>? stdinHandler;

    StreamSubscription<List<int>> stdoutHandler =
        gCloudProcess.stdout.listen((event) {
      stdout.writeln(String.fromCharCodes(event));
    });

    if (stdinStream != null) {
      stdinHandler = stdinStream!.listen((event) {
        gCloudProcess.stdin.writeln(String.fromCharCodes(event).trim());
      });
    }

    int exitCode = await gCloudProcess.exitCode;

    await stderrHandler.cancel();
    await stdinHandler?.cancel();
    await stdoutHandler.cancel();

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
