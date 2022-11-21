import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
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
import 'package:takeoff_lib/src/controllers/sonar/sonar_output.dart';
import 'package:takeoff_lib/src/controllers/sonar/sonarqube_controller.dart';
import 'package:takeoff_lib/src/hangar_scripts/common/pipeline_generator/language.dart';
import 'package:takeoff_lib/src/hangar_scripts/common/repo/repo_action.dart';
import 'package:takeoff_lib/src/hangar_scripts/common/sonarqube/setup_sonar.dart';
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
      {required String projectName,
      required String billingAccount,
      required Language backendLanguage,
      String? backendVersion,
      required Language frontendLanguage,
      String? frontendVersion,
      required String googleCloudRegion,
      StreamController<String>? infoStream}) async {
    Directory projectDir = Directory(
        "${FoldersService.containerFolders["workspace"]}/$projectName");

    logAndStream(
        "Creating folder ${FoldersService.containerFolders["workspace"]}/$projectName}",
        infoStream);

    DockerController controller = GetIt.I.get<DockerController>();
    if (!await controller.executeCommand([], ["mkdir", projectDir.path])) {
      throw CreateProjectException("Could not create project workspace");
    }

    ProjectController projectController = ProjectControllerGCloud(
        CreateProjectGCloud(
            projectName: projectName, billingAccount: billingAccount));

    logAndStream("Creating project in Google Cloud", infoStream);

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

    logAndStream(
        "Setting up principal account and verifying roles", infoStream);

    try {
      await accountController.setUpAccountAndVerifyRoles();
    } on GCloudAccountException catch (e) {
      throw CreateProjectException(
          "Could not set up the service: ${e.message}");
    }

    RepositoryController repoController = RepositoryController();

    String backendLocalDir = "${projectDir.path}/Backend";
    String frontendLocalDir = "${projectDir.path}/Frontend";

    logAndStream("Creating BackEnd Repository", infoStream);

    if (!await repoController.createRepository(CreateRepoGCloud(
        project: projectName,
        action: RepoAction.create,
        directory: backendLocalDir))) {
      throw CreateProjectException("Could not create BackEnd repository");
    }

    logAndStream("Creating FrontEnd Repository", infoStream);

    if (!await repoController.createRepository(CreateRepoGCloud(
        project: projectName,
        action: RepoAction.create,
        directory: frontendLocalDir))) {
      throw CreateProjectException("Could not create FrontEnd repository");
    }
    logAndStream("Setting up Sonarqube", infoStream);

    SonarqubeController sonarqubeController = SonarqubeController();
    if (!await sonarqubeController.execute(SetUpSonar(
        serviceAccountFile: serviceKeyPath,
        project: projectName,
        stateFolder: "$projectDir/sonarqube"))) {
      throw CreateProjectException("Could not set up SonarQube");
    }

    File sonarOutputFile =
        File("$projectDir/sonarqube/terraform.tfoutput.json");
    SonarOutput sonarOutput =
        SonarOutput.fromMap(jsonDecode(sonarOutputFile.readAsStringSync()));

    PipelineControllerGCloud pipelineController = PipelineControllerGCloud();

    logAndStream("Building BackEnd pipelines", infoStream);

    try {
      await pipelineController.buildPipelines(
          projectName: projectName,
          appEnd: ApplicationEnd.backend,
          language: backendLanguage,
          languageVersion: backendVersion,
          localDir: backendLocalDir,
          googleCloudRegion: googleCloudRegion,
          sonarUrl: sonarOutput.url,
          sonarToken: sonarOutput.token);
    } on CreatePipelineException catch (e) {
      throw CreateProjectException(
          "Could not build the BackEnd pipelines: ${e.message}");
    }
    logAndStream("Building FrontEnd pipelines", infoStream);
    try {
      await pipelineController.buildPipelines(
          projectName: projectName,
          appEnd: ApplicationEnd.frontend,
          language: frontendLanguage,
          languageVersion: frontendVersion,
          localDir: frontendLocalDir,
          googleCloudRegion: googleCloudRegion,
          sonarUrl: sonarOutput.url,
          sonarToken: sonarOutput.token);
    } on CreatePipelineException catch (e) {
      throw CreateProjectException(
          "Could not build the FrontEnd pipelines: ${e.message}");
    }

    infoStream?.add("Project $projectName succesfully created!");
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

  /// Returns the current logged Google Account or an empty String if there is none
  Future<String> getAccount() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    return await cacheRepository.getGoogleEmail();
  }

  /// Removes the project ID from the cache DB and the correspondent workspace folder
  Future<bool> cleanProject(String projectId) async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.removeGoogleProject(projectId);
    Directory projectWorkspace = Directory(join(
        GetIt.I.get<FoldersService>().getHostFolders()["workspace"]!,
        projectId));
    if (await projectWorkspace.exists()) {
      try {
        await projectWorkspace.delete(recursive: true);
      } on FileSystemException catch (e) {
        Log.error("Could not remove $projectId workspace folder: ${e.osError}");
        return false;
      }
    }
    return true;
  }

  void logAndStream(String message, StreamController<String>? stream) {
    Log.info(message);
    stream?.add(message);
  }
}
