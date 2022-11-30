import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/common/hangar/account/account_exception.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/account/setup_principal_account.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/account/verify_roles_and_permissions.dart';
import 'package:takeoff_lib/src/utils/logger/log.dart';

class AccountControllerGCloud {
  final VerifyRolesAndPermissionsGCloud verifyRolesScript;
  final SetUpPrincipalAccountGCloud setUpAccountScript;

  AccountControllerGCloud(this.setUpAccountScript, this.verifyRolesScript);

  /// Sets up the service account for the project with the specified permissions and roles.
  ///
  /// If there is an error, a [AccountException] will be thrown with
  /// a message indicating where the error was located.
  ///
  /// It does not return a boolean value. Instead, it throws a custom exception,
  /// due to it having more than one point of failure. Exceptions provide a way
  /// for the user to locate the error.
  Future<void> setUpAccountAndVerifyRoles() async {
    DockerController controller = GetIt.I.get<DockerController>();

    if (!await controller.executeCommand([], setUpAccountScript.toCommand())) {
      String errorMessage = "Could not set up the project account";
      Log.error(errorMessage);
      throw AccountException(errorMessage);
    }

    if (!await controller.executeCommand([], verifyRolesScript.toCommand())) {
      String errorMessage = "Could not verify the roles of the account";
      Log.error(errorMessage);
      throw AccountException(errorMessage);
    }

    if (!await controller.executeCommand([], [
      "gcloud",
      "auth",
      "activate-service-account",
      "${setUpAccountScript.serviceAccount}@${setUpAccountScript.projectId}.iam.gserviceaccount.com",
      "--key-file",
      setUpAccountScript.serviceKeyPath!
    ])) {
      String errorMessage = "Could not activate the service account";
      Log.error(errorMessage);
      throw AccountException(errorMessage);
    }

    // TODO: Check if we need to set the GOOGLE_APPLICATION_CREDENTIALS env variable
  }
}
