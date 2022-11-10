import 'dart:convert';
import 'dart:io';

import 'package:takeoff_lib/src/controllers/auth/auth_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller_factory.dart';
import 'package:takeoff_lib/src/domain/gcloud.dart';

class GCloudAuthController extends AuthController<GCloud> {
  @override
  Future<bool> authenticate(String email) async {
    DockerController dockerController = await DockerControllerFactory.create();
    //await dockerController
    //.executeCommandInteractive([], ["gcloud", "auth", "login", email]);
    await dockerController.executeCommandInteractive([], ["bash"]);

    return true;
  }
}
