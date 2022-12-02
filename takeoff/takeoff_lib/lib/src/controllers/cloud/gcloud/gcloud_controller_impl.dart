import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/auth/gcloud_auth_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/gcloud_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/account/account_controller_gcloud.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/quickstart/cloud_run_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/quickstart/cloud_run_exception.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/quickstart/firebase_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/hangar/account/account_exception.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/quickstart/setup_firebase_exception.dart';
import 'package:takeoff_lib/src/domain/application_end.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/hangar/pipeline/create_pipeline_exception.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/pipeline/pipeline_controller_gcloud.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/hangar/project/project_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/project/project_controller_gcloud.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/quickstart/wayat_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/hangar/quickstart/wayat_exception.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/hangar/repository/repository_controller.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/common/repo/branch_strategy.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/flutter_platform.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/flutter_web_renderer.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/quickstart/wayat_frontend.dart';
import 'package:takeoff_lib/src/domain/sonar_output.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/hangar/sonar/sonarqube_controller.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/common/repo/repo_action.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/common/sonarqube/setup_sonar.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/project/create_project.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/account/setup_principal_account.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/account/verify_roles_and_permissions.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/quickstart/init_cloud_run.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/quickstart/setup_firebase.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/quickstart/wayat_backend.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/repo/create_repo.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

/// Centralizes all the operations related with Google Cloud, such as
/// creating a project, quickstarting wayat, account management or list projects
class GoogleCloudControllerImpl implements GoogleCloudController {
  FoldersService foldersService = GetIt.I.get<FoldersService>();

  @override
  Future<bool> createProject({
    required String projectName,
    required String billingAccount,
    Language? backendLanguage,
    String? backendVersion,
    Language? frontendLanguage,
    String? frontendVersion,
    required String googleCloudRegion,
    StreamController<String>? inputStream,
    StreamController<GuiMessage>? outputStream,
    String backRepoName = "Backend",
    String frontRepoName = "Frontend",
    RepoAction frontRepoAction = RepoAction.create,
    RepoAction backRepoAction = RepoAction.create,
    String? frontImportUrl,
    String? backImportUrl,
    String? frontRepoSubpath,
    String? backRepoSubpath,
    bool wayat = false,
  }) async {
    if (backendLanguage == null && frontendLanguage == null) {
      throw CreateProjectException(
          "To create a project specify at least a BackEnd or FrontEnd language");
    }

    await _checkAuthentication();
    _logAndStream(
        GuiMessage.info(
            "Creating folder ${FoldersService.containerFolders["workspace"]}/$projectName"),
        outputStream);

    Directory projectDir = await _createWorkspaceFolder(projectName);

    ProjectController projectController = ProjectControllerGCloud(
        CreateProjectGCloud(
            projectName: projectName, billingAccount: billingAccount));

    _logAndStream(
        GuiMessage.info("Creating project in Google Cloud"), outputStream);

    if (!await projectController.createProject()) {
      throw CreateProjectException("Could not create project in Google Cloud");
    }

    String serviceKeyPath = "${projectDir.path}/key.json";

    AccountControllerGCloud accountController =
        setUpServiceAccount(projectName, serviceKeyPath);

    _logAndStream(
        GuiMessage.info("Setting up principal account and verifying roles"),
        outputStream);

    await _verifyServiceAccountRoles(accountController);

    String backendLocalDir = "${projectDir.path}/$backRepoName";
    String frontendLocalDir = "${projectDir.path}/$frontRepoName";

    await _createRepositories(projectName, projectDir, outputStream,
        backendLanguage: backendLanguage,
        frontendLanguage: frontendLanguage,
        frontendRepoName: frontRepoName,
        backendRepoName: backRepoName,
        backAction: backRepoAction,
        frontAction: frontRepoAction,
        frontImportUrl: frontImportUrl,
        backImportUrl: backImportUrl,
        frontSubpath: frontRepoSubpath,
        backSubpath: backRepoSubpath);

    _logAndStream(GuiMessage.info("Setting up Sonarqube"), outputStream);

    SonarOutput sonarOutput = await _setUpSonarqube(
      serviceKeyPath,
      projectName,
      projectDir,
    );

    if (wayat) {
      await _setUpWayatRepos(projectDir, projectName, googleCloudRegion,
          backendLocalDir, frontendLocalDir, outputStream, outputStream);
    }

    PipelineControllerGCloud pipelineController = PipelineControllerGCloud();

    if (backendLanguage != null) {
      _logAndStream(
          GuiMessage.info("Building BackEnd pipelines"), outputStream);

      await buildPipelines(
          pipelineController: pipelineController,
          projectName: projectName,
          appEnd: ApplicationEnd.backend,
          language: backendLanguage,
          languageVersion: backendVersion,
          localDir: backendLocalDir,
          googleCloudRegion: googleCloudRegion,
          sonarOutput: sonarOutput);
    }

    if (frontendLanguage != null) {
      _logAndStream(
          GuiMessage.info("Building FrontEnd pipelines"), outputStream);

      await buildPipelines(
          pipelineController: pipelineController,
          projectName: projectName,
          appEnd: ApplicationEnd.frontend,
          language: frontendLanguage,
          languageVersion: frontendVersion,
          localDir: frontendLocalDir,
          googleCloudRegion: googleCloudRegion,
          sonarOutput: sonarOutput,
          registryLocation: googleCloudRegion,
          flutterPlatform: (frontendLanguage == Language.flutter)
              ? FlutterPlatform.web
              : null,
          flutterWebRenderer: (frontendLanguage == Language.flutter)
              ? FlutterWebRenderer.canvaskit
              : null);

      if (wayat) {
        _logAndStream(
            GuiMessage.info("Building Android pipelines"), outputStream);

        await buildPipelines(
            pipelineController: pipelineController,
            projectName: projectName,
            appEnd: ApplicationEnd.frontend,
            language: frontendLanguage,
            languageVersion: frontendVersion,
            localDir: frontendLocalDir,
            googleCloudRegion: googleCloudRegion,
            sonarOutput: sonarOutput,
            registryLocation: googleCloudRegion,
            flutterPlatform: FlutterPlatform.android);
      }
    }

    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.saveGoogleProjectId(projectName);

    Log.success("Project $projectName succesfully created!");
    outputStream?.add(GuiMessage.success("Project created successfully",
        "https://console.cloud.google.com/welcome?project=$projectName"));
    Log.success(
        "You can view the project by entering in: https://console.cloud.google.com/welcome?project=$projectName");

    return true;
  }

  @override
  Future<bool> run(String projectId) async {
    CacheRepository cacheRepository = CacheRepositoryImpl();

    await _checkAuthentication();

    if (!(await cacheRepository.getGoogleProjectIds()).contains(projectId)) {
      Log.error("The project $projectId does not exist in the TakeOff cache");
      return false;
    }

    Directory projectFolder = Directory(
        join(foldersService.getHostFolders()["workspace"]!, projectId));

    if (!projectFolder.existsSync()) {
      Log.error("The workspace folder of $projectId does not exist");
      return false;
    }

    DockerController controller = GetIt.I.get<DockerController>();
    await controller.executeCommand([
      "-it",
      "--workdir",
      "/scripts/workspace/$projectId"
    ], [
      "/bin/bash",
      "-c",
      "gcloud config set project $projectId && gcloud beta interactive && exit"
    ], startMode: ProcessStartMode.detached, runInShell: true);

    return true;
  }

  @override
  Future<bool> init(String email,
      {bool useStdin = false,
      GCloudAuthController? controller,
      Stream<List<int>>? stdinStream}) async {
    GCloudAuthController authController = controller ??
        GCloudAuthController(useStdin: useStdin, stdinStream: stdinStream);
    return await authController.authenticate(email);
  }

  @override
  Future<String> getAccount(
      {GCloudAuthController? controller,
      Stream<List<int>>? stdinStream}) async {
    GCloudAuthController authController = controller ?? GCloudAuthController();
    return await authController.getCurrentAccount();
  }

  @override
  Future<bool> logOut(
      {GCloudAuthController? controller,
      Stream<List<int>>? stdinStream}) async {
    GCloudAuthController authController = controller ?? GCloudAuthController();
    return await authController.logOut();
  }

  @override
  Future<bool> cleanProject(String projectId) async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.removeGoogleProject(projectId);
    Directory projectWorkspace = Directory(
        join(foldersService.getHostFolders()["workspace"]!, projectId));
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

  @override
  Future<bool> wayatQuickstart(
      {required String billingAccount,
      required String googleCloudRegion,
      StreamController<String>? inputStream,
      StreamController<GuiMessage>? outputStream}) async {
    DateTime now = DateTime.now();
    String projectName =
        "wayat-takeoff-${now.hour}-${now.minute}-${now.second}-${now.day}-${now.month}-${now.year}"
            .substring(0, 29);
    FirebaseController firebaseController = FirebaseController();
    await firebaseController.authenticate(outputStream, inputStream);

    return await createProject(
        projectName: projectName,
        billingAccount: billingAccount,
        backendLanguage: Language.python,
        backendVersion: "3.10",
        frontendLanguage: Language.flutter,
        frontendVersion: "3.3.6",
        googleCloudRegion: googleCloudRegion,
        inputStream: inputStream,
        outputStream: outputStream,
        backRepoName: "wayat-python",
        frontRepoName: "wayat-flutter",
        wayat: true);
  }

  /// Helper method that will set run the specific wayat scripts when executing [wayatQuickstart].
  Future<void> _setUpWayatRepos(
    Directory projectDir,
    String projectName,
    String googleCloudRegion,
    String backendLocalDir,
    String frontendLocalDir,
    StreamController<GuiMessage>? inputStream,
    StreamController<GuiMessage>? outputStream,
  ) async {
    _logAndStream(GuiMessage.info("Initializing Cloud Run"), inputStream);

    String frontUrlCloudRun = "${projectDir.path}/frontUrlCloudRun";
    String backUrlCloudRun = "${projectDir.path}/backUrlCloudRun";

    await _initCloudRun(projectDir, projectName, googleCloudRegion,
        frontUrlCloudRun, backUrlCloudRun);

    File frontendUrlFile = File(
        "${foldersService.getHostFolders()["workspace"]!}${Platform.pathSeparator}$projectName${Platform.pathSeparator}frontUrlCloudRun");
    File backendUrlFile = File(
        "${foldersService.getHostFolders()["workspace"]!}${Platform.pathSeparator}$projectName${Platform.pathSeparator}backUrlCloudRun");

    String frontendUrl = frontendUrlFile.readAsStringSync();
    String backendUrl = backendUrlFile.readAsStringSync();

    _logAndStream(
        GuiMessage.info("Setting up Firebase & Firestore"), inputStream);

    await _setUpFirebase(projectName, projectDir.path,
        enableMaps: true,
        setUpAndroid: true,
        setUpIos: true,
        setUpWeb: true,
        firestoreRegion: googleCloudRegion);

    String acceptConsentUrl =
        "https://console.cloud.google.com/apis/credentials/consent?project=$projectName";

    if (outputStream != null) {
      outputStream.add(GuiMessage.browser(
          "Accept Firebase's terms of service", acceptConsentUrl));
      await inputStream?.stream.take(1).last;
    } else {
      Log.info(
          "\n\n===========================\n\nOpen $acceptConsentUrl and accept the terms of Firebase\n\n===========================\n\n");
      Log.info("Press enter to continue");
      stdin.readLineSync();
    }

    String mapsStaticSecretUrl =
        "https://console.cloud.google.com/google/maps-apis/api-list?project=$projectName";
    String mapsStaticSecret = "";

    if (outputStream != null) {
      outputStream.add(GuiMessage.browser(
          "Open the page and copy the Maps Secret", mapsStaticSecretUrl));
      await inputStream?.stream.take(1).last;
      outputStream
          .add(GuiMessage.input("Introduce the Maps Secret", InputType.text));
      mapsStaticSecret = (await inputStream?.stream.take(1).last)!.message;
    } else {
      Log.info(
          "\n\n===========================\n\nOpen $mapsStaticSecretUrl and copy the maps secret\n\n===========================\n\n");
      Log.info("Introduce the maps secret:");
      mapsStaticSecret = stdin.readLineSync() ?? "";
      while (mapsStaticSecret.isEmpty) {
        Log.warning("Maps secret cannot be empty");
        mapsStaticSecret = stdin.readLineSync() ?? "";
      }
    }

    _logAndStream(GuiMessage.info("Setting up Wayat secrets"), inputStream);

    WayatController wayatController = WayatController();
    try {
      await wayatController.setUpWayat(WayatBackend(
          projectName: projectName,
          workspace: projectDir.path,
          backendRepoDir: backendLocalDir,
          storageBucket: "$projectName.appspot.com"));

      await wayatController.setUpWayat(WayatFrontend(
          projectName: projectName,
          workspace: projectDir.path,
          frontendRepoDir: frontendLocalDir,
          keystoreFile: "${projectDir.path}/keystore.jks",
          backendUrl: backendUrl,
          frontendUrl: frontendUrl,
          mapsStaticSecret: mapsStaticSecret));
    } on WayatException catch (e) {
      throw CreateProjectException(e.message);
    }
  }

  /// Helper method to initialize Cloud Run in [wayatQuickstart]
  Future<void> _initCloudRun(
      Directory projectDir,
      String projectName,
      String googleCloudRegion,
      String frontUrlCloudRun,
      String backUrlCloudRun) async {
    CloudRunController cloudRunController = CloudRunController();
    try {
      await cloudRunController.initCloudRun(InitCloudRun(
          project: projectName,
          name: "wayat-front",
          region: googleCloudRegion,
          urlOutputFile: frontUrlCloudRun));
    } on CloudRunException catch (e) {
      throw CreateProjectException(e.message);
    }
    try {
      await cloudRunController.initCloudRun(InitCloudRun(
          project: projectName,
          name: "wayat-back",
          region: googleCloudRegion,
          urlOutputFile: backUrlCloudRun));
    } on CloudRunException catch (e) {
      throw CreateProjectException(e.message);
    }
  }

  /// Helper method to set up firebase in [wayatQuickstart]
  Future<void> _setUpFirebase(String projectName, String credentialsOutput,
      {String? firestoreRegion,
      bool? enableMaps,
      bool? setUpAndroid,
      bool? setUpIos,
      bool? setUpWeb}) async {
    FirebaseController controller = FirebaseController();
    try {
      await controller.setUpFirebase(SetUpFirebase(
          projectName: projectName,
          credentialsOutputFolder: credentialsOutput,
          setUpAndroid: setUpAndroid,
          setUpIOS: setUpIos,
          setUpWeb: setUpWeb,
          firestoreRegion: firestoreRegion,
          enableMaps: enableMaps));
    } on SetUpFirebaseException catch (e) {
      throw CreateProjectException(e.message);
    }
  }

  /// Helper method to check that there is a logged user in Google Cloud in
  /// [wayatQuickstart] and [createProject]
  Future<String> _checkAuthentication() async {
    GCloudAuthController gCloudAuthController = GCloudAuthController();
    String currentAccount = await gCloudAuthController.getCurrentAccount();
    if (currentAccount.isEmpty) {
      throw CreateProjectException(
          "You need to be logged in Google Cloud. Execute the init command for Google Cloud.");
    }
    await gCloudAuthController.authenticate(
      currentAccount,
    );
    return currentAccount;
  }

  /// Helper method to create the folder for [wayatQuickstart] and [createProject]
  Future<Directory> _createWorkspaceFolder(String projectName) async {
    Directory projectDir = Directory(
        "${FoldersService.containerFolders["workspace"]}/$projectName");

    DockerController controller = GetIt.I.get<DockerController>();
    if (!await controller.executeCommand([], ["mkdir", projectDir.path])) {
      throw CreateProjectException("Could not create project workspace");
    }
    return projectDir;
  }

  /// helper method to set up sonarqube for [wayatquickstart] and [createproject]
  Future<SonarOutput> _setUpSonarqube(
      String serviceKeyPath, String projectName, Directory projectDir) async {
    SonarqubeController sonarqubeController = SonarqubeController();
    if (!await sonarqubeController.execute(
        SetUpSonar(
            serviceAccountFile: serviceKeyPath,
            project: projectName,
            stateFolder: "${projectDir.path}/sonarqube"),
        "gcloud")) {
      throw CreateProjectException("Could not set up SonarQube");
    }

    File sonarOutputFile = File(
        "${foldersService.getHostFolders()["workspace"]!}${Platform.pathSeparator}$projectName${Platform.pathSeparator}sonarqube${Platform.pathSeparator}terraform.tfoutput.json");
    SonarOutput sonarOutput =
        SonarOutput.fromMap(jsonDecode(sonarOutputFile.readAsStringSync()));
    return sonarOutput;
  }

  /// Helper method to create the service account for [wayatQuickstart] and [createProject]
  AccountControllerGCloud setUpServiceAccount(
      String projectName, String serviceKeyPath) {
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
    return accountController;
  }

  Future<void> buildPipelines(
      {required PipelineControllerGCloud pipelineController,
      required String projectName,
      required ApplicationEnd appEnd,
      required Language language,
      required String localDir,
      required String googleCloudRegion,
      required SonarOutput sonarOutput,
      String? languageVersion,
      String? registryLocation,
      FlutterPlatform? flutterPlatform,
      FlutterWebRenderer? flutterWebRenderer}) async {
    try {
      await pipelineController.buildPipelines(
        projectName: projectName,
        appEnd: appEnd,
        language: language,
        languageVersion: languageVersion,
        localDir: localDir,
        googleCloudRegion: googleCloudRegion,
        sonarUrl: sonarOutput.url,
        sonarToken: sonarOutput.token,
        registryLocation: registryLocation,
        flutterPlatform: flutterPlatform,
        flutterWebRenderer: flutterWebRenderer,
      );
    } on CreatePipelineException catch (e) {
      throw CreateProjectException(
          "Could not build the ${appEnd.name} pipelines: ${e.message}");
    }
  }

  /// Helper method to create the repositories for [wayatQuickstart] and [createProject]
  Future<void> _createRepositories(String projectName, Directory projectDir,
      StreamController<GuiMessage>? outputStream,
      {required Language? backendLanguage,
      required Language? frontendLanguage,
      RepoAction frontAction = RepoAction.create,
      RepoAction backAction = RepoAction.create,
      String? frontImportUrl,
      String? backImportUrl,
      String? frontSubpath,
      String? backSubpath,
      String backendRepoName = "Backend",
      String frontendRepoName = "Frontend"}) async {
    RepositoryController repoController = RepositoryController();

    if (backendLanguage != null) {
      _logAndStream(
          GuiMessage.info("Creating BackEnd repository"), outputStream);

      if (!await repoController.createRepository(CreateRepoGCloud(
          name: backendRepoName,
          project: projectName,
          subpath: backSubpath,
          setUpBranchStrategy: BranchStrategy.gitflow,
          action: backAction,
          sourceGitUrl: backImportUrl,
          directory: projectDir.path))) {
        throw CreateProjectException("Could not create BackEnd repository");
      }
    }
    if (frontendLanguage != null) {
      _logAndStream(
          GuiMessage.info("Creating FrontEnd Repository"), outputStream);

      if (!await repoController.createRepository(CreateRepoGCloud(
          name: frontendRepoName,
          project: projectName,
          sourceGitUrl: frontImportUrl,
          subpath: frontSubpath,
          setUpBranchStrategy: BranchStrategy.gitflow,
          action: frontAction,
          directory: projectDir.path))) {
        throw CreateProjectException("Could not create FrontEnd repository");
      }
    }
  }

  /// Helper method to verify the service accounts roles for [wayatQuickstart] and [createProject]
  Future<void> _verifyServiceAccountRoles(
      AccountControllerGCloud accountController) async {
    try {
      await accountController.setUpAccountAndVerifyRoles();
    } on AccountException catch (e) {
      throw CreateProjectException(
          "Could not set up the service: ${e.message}");
    }
  }

  /// Helper method to log into the console and the GUI stream for [wayatQuickstart] and [createProject]
  void _logAndStream(GuiMessage message, StreamController<GuiMessage>? stream) {
    Log.info(message.message);
    stream?.add(message);
  }
}
