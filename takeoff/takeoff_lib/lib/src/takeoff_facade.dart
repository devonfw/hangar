import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:takeoff_lib/src/controllers/auth/auth_controller.dart';
import 'package:takeoff_lib/src/controllers/auth/gcloud_auth_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller_factory.dart';
import 'package:takeoff_lib/src/controllers/hangar/account/account_controller.dart';
import 'package:takeoff_lib/src/controllers/hangar/account/account_controller_gcloud.dart';
import 'package:takeoff_lib/src/controllers/hangar/project/project_controller.dart';
import 'package:takeoff_lib/src/controllers/hangar/project/project_controller_gcloud.dart';
import 'package:takeoff_lib/src/domain/gcloud.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/account/create_project.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/account/setup_principal_account.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/account/verify_roles_and_permissions.dart';
import 'package:takeoff_lib/src/persistence/database/database_singleton.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:takeoff_lib/src/utils/system/system_service.dart';

class TakeOffFacade {
  /// Initializes all the singletons neeeded for the app to run and checks prerequisites.
  ///
  /// The singletons are the [DockerController] and the [Database] instances.
  /// The [DockerController] is initialized as a singleton to avoid checking the
  /// docker installation multiple times during the execution, consuming unnecessary resources.
  Future<bool> initialize() async {
    GetIt.I.registerSingleton<PlatformService>(PlatformService());
    GetIt.I.registerSingleton<FoldersService>(FoldersService());
    DockerController dockerController =
        await DockerControllerFactory().create();
    GetIt.I.registerLazySingleton<DockerController>(() => dockerController);
    GetIt.I.registerSingleton<Database>(await DatabaseSingleton().initialize());

    return await SystemService().checkSystemPrerequisites();
  }

  /// Logs in with Google Cloud.
  ///
  /// Receives the [email] to log in and an optional [GCloudAuthController] for testing purposes.
  Future<bool> initGoogleCloud(String email,
      {AuthController<GCloud>? controller}) async {
    AuthController<GCloud> authController =
        controller ?? GCloudAuthController();
    return await authController.authenticate(email);
  }

  Future<bool> createProjectGCloud(
      String projectName, String billingAccount) async {
    //Directory directory = Directory("/scripts/workspace/$projectName");

    ProjectController projectController = ProjectControllerGCloud(
        CreateProjectGCloud(
            projectName: projectName, billingAccount: billingAccount));

    if (!await projectController.createProject()) {
      return false;
    }

    //String currentAccount = await GCloudAuthController().getCurrentAccount();

    AccountController accountController = AccountControllerGCloud(
        SetUpPrincipalAccountGCloud(
            googleAccount: "",
            serviceAccount: "TakeOff",
            projectId: projectName),
        VerifyRolesAndPermissionsGCloud(
            googleAccount: "",
            serviceAccount: "TakeOff",
            projectId: projectName));

    if (!await accountController.setUpAccountAndVerifyRoles()) {
      return false;
    }

    return true;
  }
}
