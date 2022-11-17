import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/auth/gcloud_auth_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud_providers/create_project_exception.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/hangar/account/account_controller_gcloud.dart';
import 'package:takeoff_lib/src/controllers/hangar/account/gcloud_account_exception.dart';
import 'package:takeoff_lib/src/controllers/hangar/pipeline/application_end.dart';
import 'package:takeoff_lib/src/controllers/hangar/pipeline/create_pipeline_exception.dart';
import 'package:takeoff_lib/src/controllers/hangar/pipeline/pipeline_controller_gcloud.dart';
import 'package:takeoff_lib/src/controllers/hangar/project/project_controller.dart';
import 'package:takeoff_lib/src/controllers/hangar/project/project_controller_gcloud.dart';
import 'package:takeoff_lib/src/controllers/hangar/repository/repository_controller.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/hangar_scripts/common/pipeline_generator/language.dart';
import 'package:takeoff_lib/src/hangar_scripts/common/repo/repo_action.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/account/create_project.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/account/setup_principal_account.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/account/verify_roles_and_permissions.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/repo/create_repo.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/logger/log.dart';

class GoogleCloudController {
  /// Creates a project in Google Cloud
  Future<bool> createProject(
      String projectName,
      String billingAccount,
      Language backendLanguage,
      Language frontendLanguage,
      String googleCloudRegion) async {
    Directory projectDir = Directory(
        "${FoldersService.containerFolders["workspace"]}/$projectName");

    DockerController controller = GetIt.I.get<DockerController>();
    if (!await controller.executeCommand([], ["mkdir", projectDir.path])) {
      throw CreateProjectException("Could not create project workspace");
    }

    ProjectController projectController = ProjectControllerGCloud(
        CreateProjectGCloud(
            projectName: projectName, billingAccount: billingAccount));

    if (!await projectController.createProject()) {
      throw CreateProjectException("Could not create project in Google Cloud");
    }

    String serviceKeyPath = "${projectDir.path}/key.json";

    AccountControllerGCloud accountController = AccountControllerGCloud(
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

    try {
      await accountController.setUpAccountAndVerifyRoles();
    } on GCloudAccountException catch (e) {
      throw CreateProjectException(
          "Could not set up the service: ${e.message}");
    }

    RepositoryController repoController = RepositoryController();

    String backendLocalDir = "${projectDir.path}/Backend";
    String frontendLocalDir = "${projectDir.path}/Frontend";

    if (!await repoController.createRepository(CreateRepoGCloud(
        project: projectName,
        action: RepoAction.create,
        directory: backendLocalDir))) {
      throw CreateProjectException("Could not create BackEnd repository");
    }

    if (!await repoController.createRepository(CreateRepoGCloud(
        project: projectName,
        action: RepoAction.create,
        directory: frontendLocalDir))) {
      throw CreateProjectException("Could not create FrontEnd repository");
    }

    PipelineControllerGCloud pipelineController = PipelineControllerGCloud();

    try {
      await pipelineController.buildPipelines(
          projectName,
          ApplicationEnd.backend,
          backendLanguage,
          backendLocalDir,
          googleCloudRegion);
    } on CreatePipelineException catch (e) {
      throw CreateProjectException(
          "Could not build the BackEnd pipelines: ${e.message}");
    }
    try {
      await pipelineController.buildPipelines(
          projectName,
          ApplicationEnd.frontend,
          frontendLanguage,
          frontendLocalDir,
          googleCloudRegion);
    } on CreatePipelineException catch (e) {
      throw CreateProjectException(
          "Could not build the FrontEnd pipelines: ${e.message}");
    }

    Log.success("Project $projectName succesfully created!");

    return true;
  }

  /// Logs in with Google Cloud.
  ///
  /// Receives the [email] to log in, an optional [GCloudAuthController] for
  /// testing purposes and a stdin stream for the GUI client to be able to write
  /// to the authentication process.
  Future<bool> init(String email,
      {GCloudAuthController? controller,
      Stream<List<int>>? stdinStream}) async {
    GCloudAuthController authController =
        controller ?? GCloudAuthController(stdinStream: stdinStream);
    return await authController.authenticate(email);
  }

  Future<String> getAccount() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    return await cacheRepository.getGoogleEmail();
  }
}
