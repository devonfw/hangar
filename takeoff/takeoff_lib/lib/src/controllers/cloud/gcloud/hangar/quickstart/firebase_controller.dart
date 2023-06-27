import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/quickstart/setup_firebase_exception.dart';
import 'package:takeoff_lib/src/domain/gui_message/gui_message.dart';
import 'package:takeoff_lib/src/domain/gui_message/input_type.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/quickstart/setup_firebase.dart';
import 'package:takeoff_lib/src/utils/logger/log.dart';
import 'package:takeoff_lib/src/utils/url_launcher/url_launcher.dart';

class FirebaseController {
  Future<bool> authenticate(StreamController<GuiMessage>? outputStream,
      StreamController<String>? inputStream) async {
    DockerController controller = GetIt.I.get<DockerController>();

    List<String> volumeMappings = controller.getVolumeMappings();

    List<String> args = ["run", "--rm", "-i"] +
        volumeMappings +
        [DockerController.imageName] +
        ["firebase", "login", "--interactive", "--no-localhost"];

    Process dockerProc =
        await Process.start(controller.command, args, runInShell: true);

    bool deniedDataCollection = false;
    bool logged = false;
    String url = "";
    String sessionId = "";

    dockerProc.stdout.listen((event) async {
      String output = String.fromCharCodes(event).trim();
      if (logged) return;

      if (!deniedDataCollection) {
        dockerProc.stdin.writeln("n");
        deniedDataCollection = true;
        return;
      }

      for (String line in output.split("\n")) {
        line = line.trim();
        if (sessionId.isEmpty && line.length == 5) {
          sessionId = line;
          continue;
        }

        if (url.isEmpty && line.contains("https://")) {
          url = line;
          continue;
        }

        if (line.contains("Enter authorization code:")) {
          Log.info(
              "Your session ID is: $sessionId\nFollow the instructions in your browser and "
              "enter your authorization code:");
          await UrlLaucher().launch(url);
          late String code;
          if (outputStream == null) {
            code = stdin.readLineSync() ?? "";
            while (code.isEmpty) {
              Log.info("Enter the authorization code:");
              code = stdin.readLineSync() ?? "";
            }
          } else {
            outputStream.add(GuiMessage.input(
                "Your session ID is: $sessionId. Follow "
                "the instructions in:\n$url\nand enter your authorization code.",
                InputType.text));
            code = await inputStream?.stream.take(1).last ?? "";
            while (code.isEmpty) {
              outputStream.add(GuiMessage.input(
                  "Your session ID is: $sessionId. Follow "
                  "the instructions in:\n$url\nand enter your authorization code.",
                  InputType.text));
              code = await inputStream?.stream.take(1).last ?? "";
            }
          }
          dockerProc.stdin.writeln(code);
          logged = true;
        }
      }
    });
    stderr.addStream(dockerProc.stderr);
    bool res = await dockerProc.exitCode == 0;
    if (res) {
      Log.success("Logged in with firebase");
      outputStream?.add(GuiMessage.info("Logged in with firebase"));
    } else {
      Log.error("Could not log in with firebase");
      outputStream?.add(GuiMessage.error("Cloud not log in with firebase"));
    }
    return res;
  }

  Future<void> setUpFirebase(SetUpFirebase script) async {
    DockerController controller = GetIt.I.get<DockerController>();

    if (!await controller.executeCommand([], script.toCommand())) {
      throw SetUpFirebaseException("Could not set up Firebase");
    }
  }
}
