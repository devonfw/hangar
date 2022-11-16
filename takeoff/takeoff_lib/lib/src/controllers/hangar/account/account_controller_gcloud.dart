import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/hangar/account/account_controller.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/account/setup_principal_account.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/account/verify_roles_and_permissions.dart';

class AccountControllerGCloud implements AccountController {
  final VerifyRolesAndPermissionsGCloud verifyRolesScript;
  final SetUpPrincipalAccountGCloud setUpAccountScript;

  AccountControllerGCloud(this.setUpAccountScript, this.verifyRolesScript);

  @override
  Future<bool> setUpAccountAndVerifyRoles() async {
    DockerController controller = GetIt.I.get<DockerController>();

    if (!await controller.executeCommand([], setUpAccountScript.toCommand())) {
      return false;
    }

    if (!await controller.executeCommand([], verifyRolesScript.toCommand())) {
      return false;
    }

    // TODO: Wait for the key.json path to be parametrized to be able to pass it
    if (!await controller.executeCommand([], [
      "gcloud",
      "auth",
      "activate-service-account",
      "${setUpAccountScript.serviceAccount}@${setUpAccountScript.projectId}.iam.gserviceaccount.com",
      "--key-file" "/scripts/workspace/${setUpAccountScript.projectId}/key.json"
    ])) {
      return false;
    }

    return true;
  }
}
