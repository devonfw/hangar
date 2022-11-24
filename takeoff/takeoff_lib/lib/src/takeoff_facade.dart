import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:takeoff_lib/src/controllers/cloud_providers/gcloud_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud_providers/gcloud_controller_impl.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller_factory.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/domain/cloud_provider_id.dart';
import 'package:takeoff_lib/src/hangar_scripts/common/pipeline_generator/language.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_singleton.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:takeoff_lib/src/utils/system/system_service.dart';

class TakeOffFacade {
  final GoogleCloudController _googleController = GoogleCloudControllerImpl();

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
      DockerController dockerController =
          await DockerControllerFactory().create();
      GetIt.I.registerLazySingleton<DockerController>(() => dockerController);
      GetIt.I
          .registerSingleton<Database>(await DatabaseSingleton().initialize());
    }

    return await SystemService().checkSystemPrerequisites();
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
        return await _googleController.init(email, stdinStream: stdinStream);
      case CloudProviderId.aws:
        return false;
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
        return false;
      case CloudProviderId.azure:
        return false;
    }
  }

  /// Calls the method that will create a project in Google Cloud.
  Future<bool> createProjectGCloud(
      {required String projectName,
      required String billingAccount,
      required Language backendLanguage,
      String? backendVersion,
      required Language frontendLanguage,
      String? frontendVersion,
      required String googleCloudRegion,
      StreamController<String>? infoStream}) async {
    return await _googleController.createProject(
        projectName: projectName,
        billingAccount: billingAccount,
        backendLanguage: backendLanguage,
        backendVersion: backendVersion,
        frontendLanguage: frontendLanguage,
        frontendVersion: frontendVersion,
        googleCloudRegion: googleCloudRegion,
        infoStream: infoStream);
  }

  /// Creates Wayat in Google Cloud
  Future<bool> quickstartWayat(
      {required String billingAccount,
      required String googleCloudRegion,
      StreamController<String>? infoStream}) async {
    return await _googleController.wayatQuickstart(
        billingAccount: billingAccount,
        googleCloudRegion: googleCloudRegion,
        infoStream: infoStream);
  }

  Future<bool> cleanProject(
      CloudProviderId cloudProvider, String projectId) async {
    switch (cloudProvider) {
      case CloudProviderId.gcloud:
        return await _googleController.cleanProject(projectId);
      case CloudProviderId.aws:
        return false;
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
        return [];
      case CloudProviderId.azure:
        return [];
    }
  }
}
