import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:takeoff_lib/src/controllers/auth/auth_controller.dart';
import 'package:takeoff_lib/src/controllers/auth/gcloud_auth_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller_factory.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/domain/cloud_provider_enum.dart';
import 'package:takeoff_lib/src/domain/gcloud.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
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

  /// Logs into the [cloudProvider] with [email].
  ///
  /// Returns whether the process is succesful.
  Future<bool> init(String email, CloudProviderId cloudProvider) async {
    switch (cloudProvider) {
      case CloudProviderId.gcloud:
        return await _initGoogleCloud(email);
      case CloudProviderId.aws:
        return false;
      case CloudProviderId.azure:
        return false;
    }
  }

  /// Logs in with Google Cloud.
  ///
  /// Receives the [email] to log in and an optional [GCloudAuthController] for testing purposes.
  Future<bool> _initGoogleCloud(String email,
      {AuthController<GCloud>? controller}) async {
    AuthController<GCloud> authController =
        controller ?? GCloudAuthController();
    return await authController.authenticate(email);
  }
}
