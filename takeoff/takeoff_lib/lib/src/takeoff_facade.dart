import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:takeoff_lib/src/controllers/auth/gcloud_auth_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller_factory.dart';
import 'package:takeoff_lib/src/controllers/hangar/repository/repository_controller_gcloud.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/domain/cloud_provider_enum.dart';
import 'package:takeoff_lib/src/controllers/hangar/account/account_controller.dart';
import 'package:takeoff_lib/src/controllers/hangar/account/account_controller_gcloud.dart';
import 'package:takeoff_lib/src/controllers/hangar/project/project_controller.dart';
import 'package:takeoff_lib/src/controllers/hangar/project/project_controller_gcloud.dart';
import 'package:takeoff_lib/src/hangar_scripts/common/repo/repo_action.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/repo/create_repo.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
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

  /// Returns the currently stored email for each Cloud Provider.
  ///
  /// Currently only Google Cloud is supported. If you introduce an unsupported
  /// provider or there is no currently logged account it will return an empty String.
  Future<String> getCurrentAccount(CloudProviderId cloudProvider) async {
    CacheRepository cacheRepository = CacheRepositoryImpl();

    switch (cloudProvider) {
      case CloudProviderId.gcloud:
        return await cacheRepository.getGoogleEmail();
      case CloudProviderId.aws:
        return "";
      case CloudProviderId.azure:
        return "";
    }
  }

  /// Logs into the [cloudProvider] with [email]. An optional [stdin] stream
  /// is passed for the Google Cloud login. It will not have any effect
  /// on any other provider.
  ///
  /// Returns whether the process is succesful.
  Future<bool> init(String email, CloudProviderId cloudProvider,
      {Stream<List<int>>? stdinStream}) async {
    switch (cloudProvider) {
      case CloudProviderId.gcloud:
        return await _initGoogleCloud(email, stdinStream: stdinStream);
      case CloudProviderId.aws:
        return false;
      case CloudProviderId.azure:
        return false;
    }
  }

  /// Logs in with Google Cloud.
  ///
  /// Receives the [email] to log in, an optional [GCloudAuthController] for
  /// testing purposes and a stdin stream for the GUI client to be able to write
  /// to the authentication process.
  Future<bool> _initGoogleCloud(String email,
      {GCloudAuthController? controller,
      Stream<List<int>>? stdinStream}) async {
    GCloudAuthController authController =
        controller ?? GCloudAuthController(stdinStream: stdinStream);
    return await authController.authenticate(email);
  }

  /// Creates a project in Google Cloud
  Future<bool> createProjectGCloud(
      String projectName, String billingAccount) async {
    Directory projectDir = Directory(
        "${FoldersService.containerFolders["workspace"]}/$projectName");

    DockerController controller = GetIt.I.get<DockerController>();
    if (!await controller.executeCommand([], ["mkdir", projectDir.path])) {
      return false;
    }

    ProjectController projectController = ProjectControllerGCloud(
        CreateProjectGCloud(
            projectName: projectName, billingAccount: billingAccount));

    if (!await projectController.createProject()) {
      return false;
    }

    String serviceKeyPath = "${projectDir.path}/key.json";

    AccountController accountController = AccountControllerGCloud(
        SetUpPrincipalAccountGCloud(
            googleAccount: "",
            serviceAccount: "TakeOff",
            projectId: projectName,
            serviceKeyPath: serviceKeyPath),
        VerifyRolesAndPermissionsGCloud(
          googleAccount: "",
          serviceAccount: "TakeOff",
          projectId: projectName,
        ));

    if (!await accountController.setUpAccountAndVerifyRoles()) {
      return false;
    }

    RepositoryControllerGCloud repoController = RepositoryControllerGCloud();

    if (!await repoController.createRepository(CreateRepoGCloud(
        project: projectName,
        action: CreateAction.create,
        directory: "${projectDir.path}/Frontend"))) {
      return false;
    }

    if (!await repoController.createRepository(CreateRepoGCloud(
        project: projectName,
        action: CreateAction.create,
        directory: "${projectDir.path}/Backend"))) {
      return false;
    }

    //https://source.cloud.google.com/qatestsfuse/python-wayat-2

    return true;
  }
}
