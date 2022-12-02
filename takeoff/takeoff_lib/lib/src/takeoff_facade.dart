import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/gcloud_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/gcloud_controller_impl.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller_factory.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_installation.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_factory.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:takeoff_lib/src/utils/system/system_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class TakeOffFacade {
  late GoogleCloudController _googleController;

  /// Initializes all the singletons neeeded for the app to run and checks prerequisites.
  ///
  /// The singletons are the [DockerController] and the [Database] instances.
  /// The [DockerController] is initialized as a singleton to avoid checking the
  /// docker installation multiple times during the execution, consuming unnecessary resources.
  Future<bool> initialize() async {
    // This conditional is used to avoid exceptions using hot reload when
    if (!GetIt.I.isRegistered<PlatformService>()) {
      GetIt.I.registerSingleton<PlatformService>(PlatformService());
      GetIt.I.registerSingleton<FoldersService>(FoldersService());
      GetIt.I.registerSingleton<DockerType>(DockerType(
          installation: DockerInstallation.unknown,
          command: DockerCommand.none));

      if (!await SystemService().checkSystemPrerequisites()) {
        return false;
      }

      DockerController dockerController =
          await DockerControllerFactory().create();
      GetIt.I.registerLazySingleton<DockerController>(() => dockerController);
      GetIt.I.registerSingleton<Database>(await DbFactory().create());
      await dockerController.pullHangarImage();

      _googleController = GoogleCloudControllerImpl();
    }

    return true;
  }

  /// Returns the currently stored email for each Cloud Provider.
  ///
  /// Currently only Google Cloud is supported. If you introduce an unsupported
  /// provider or there is no currently logged account it will return an empty String.
  Future<String> getCurrentAccount(CloudProviderId cloudProvider) async {
    switch (cloudProvider) {
      case CloudProviderId.gcloud:
        return await _googleController.getAccount();
      case CloudProviderId.aws:
      case CloudProviderId.azure:
        return "";
    }
  }

  Future<bool> runProject(String project, CloudProviderId cloudProvider) async {
    switch (cloudProvider) {
      case CloudProviderId.gcloud:
        return _googleController.run(project);
      case CloudProviderId.aws:
      case CloudProviderId.azure:
        Log.warning("Currently not supported");
        return false;
    }
  }

  /// Logs into the [cloudProvider] with [email]. An optional [stdin] stream
  /// is passed for the Google Cloud login. It will not have any effect
  /// on any other provider.
  ///
  /// Returns whether the process is succesful.
  Future<bool> init(String email, CloudProviderId cloudProvider,
      {Stream<List<int>>? stdinStream, bool useStdin = false}) async {
    switch (cloudProvider) {
      case CloudProviderId.gcloud:
        return await _googleController.init(email,
            useStdin: useStdin, stdinStream: stdinStream);
      case CloudProviderId.aws:
      case CloudProviderId.azure:
        return false;
    }
  }

  Future<bool> logOut(CloudProviderId cloudProvider,
      {Stream<List<int>>? stdinStream}) async {
    switch (cloudProvider) {
      case CloudProviderId.gcloud:
        return await _googleController.logOut();
      case CloudProviderId.aws:
      case CloudProviderId.azure:
        return false;
    }
  }

  /// Calls the method that will create a project in Google Cloud.
  Future<bool> createProjectGCloud({
    required String projectName,
    required String billingAccount,
    Language? backendLanguage,
    String? backendVersion,
    Language? frontendLanguage,
    String? frontendVersion,
    required String googleCloudRegion,
    StreamController<GuiMessage>? outputStream,
    StreamController<String>? inputStream,
  }) async {
    return await _googleController.createProject(
      projectName: projectName,
      billingAccount: billingAccount,
      backendLanguage: backendLanguage,
      backendVersion: backendVersion,
      frontendLanguage: frontendLanguage,
      frontendVersion: frontendVersion,
      googleCloudRegion: googleCloudRegion,
      inputStream: inputStream,
      outputStream: outputStream,
    );
  }

  /// Creates Wayat in Google Cloud
  Future<bool> quickstartWayat(
      {required String billingAccount,
      required String googleCloudRegion,
      StreamController<GuiMessage>? outputStream,
      StreamController<String>? inputStream}) async {
    return await _googleController.wayatQuickstart(
        billingAccount: billingAccount,
        googleCloudRegion: googleCloudRegion,
        outputStream: outputStream,
        inputStream: inputStream);
  }

  Future<bool> cleanProject(
      CloudProviderId cloudProvider, String projectId) async {
    switch (cloudProvider) {
      case CloudProviderId.gcloud:
        return await _googleController.cleanProject(projectId);
      case CloudProviderId.aws:
      case CloudProviderId.azure:
        return false;
    }
  }

  Future<List<String>> getProjects(CloudProviderId cloudProvider) async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    switch (cloudProvider) {
      case CloudProviderId.gcloud:
        return await cacheRepository.getGoogleProjectIds();
      case CloudProviderId.aws:
      case CloudProviderId.azure:
        return [];
    }
  }
}
