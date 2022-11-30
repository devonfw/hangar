import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/gcloud/hangar/quickstart/setup_firebase_exception.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/quickstart/setup_firebase.dart';

class FirebaseController {
  Future<void> setUpFirebase(SetUpFirebase script) async {
    DockerController controller = GetIt.I.get<DockerController>();

    if (!await controller
        .executeCommand([], ["mkdir", script.credentialsOutputFolder])) {
      throw SetUpFirebaseException(
          "Could not create Firebase credentials output folder");
    }

    if (!await controller.executeCommand([], script.toCommand())) {
      throw SetUpFirebaseException("Could not set up Firebase");
    }
  }
}
