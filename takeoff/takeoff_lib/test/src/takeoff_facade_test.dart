import 'dart:io';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/auth/auth_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/gcloud_controller.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/gcloud_controller_impl.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/domain/cloud_provider.dart';
import 'package:takeoff_lib/src/domain/cloud_provider_id.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_factory.dart';
import 'package:takeoff_lib/src/takeoff_facade.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:test/test.dart';

import 'takeoff_facade_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DockerController>(), MockSpec<AuthController<CloudProvider>>(), MockSpec<GoogleCloudController>()])
void main() {
  MockDockerController mockDockerController = MockDockerController();
  MockGoogleCloudController mockGoogleCloudController = MockGoogleCloudController();
  // MockAuthController mockAuthController = MockAuthController();
  late FoldersService foldersService;
  setUpAll(() {
    // GetIt.I.registerSingleton<AuthController<CloudProvider>>(mockAuthController);
    GetIt.I.registerSingleton<DockerController>(mockDockerController);
    GetIt.I.registerSingleton(PlatformService());
    foldersService = FoldersService();
    GetIt.I.registerSingleton(foldersService);
  });

  setUp(() async {
    GetIt.I.registerSingleton<Database>(
        await DbFactory(dbPath: "facade_test.db").create());
  });

  test(
      "getCurrentAccount returns empty for Google Cloud if there is no logged account",
      () async {
    TakeOffFacade facade = TakeOffFacade();
    facade.googleController = mockGoogleCloudController;

    expect(await facade.getCurrentAccount(CloudProviderId.gcloud), "");
  });

  test("getCurrentAccount returns the current stored Google Cloud email",
      () async {
    TakeOffFacade facade = TakeOffFacade();
    facade.googleController = GoogleCloudControllerImpl();
    String email = "${Random().nextInt(100000000)}@mail.com";
    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.saveGoogleEmail(email);

    expect(await facade.getCurrentAccount(CloudProviderId.gcloud), email);
  });

  test(
      "getProjects returns empty for Google Cloud if there is no created projects",
      () async {
    TakeOffFacade facade = TakeOffFacade();
    facade.googleController = mockGoogleCloudController;

    expect(await facade.getProjects(CloudProviderId.gcloud), []);
  });

  test("getProjects returns the correct Google Cloud projects", () async {
    CacheRepository cacheRepository = CacheRepositoryImpl();

    String email = "${Random().nextInt(100000000)}@mail.com";
    await cacheRepository.saveGoogleEmail(email);

    TakeOffFacade takeOffFacade = TakeOffFacade();
    List<String> projects = List.generate(
        Random().nextInt(15) + 5, (_) => Random().nextInt(1000000).toString());
    for (String elem in projects) {
      await cacheRepository.saveGoogleProjectId(elem);
    }

    expect(projects, await takeOffFacade.getProjects(CloudProviderId.gcloud));
  });

  test("Clean project in Google Cloud is correct", () async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String projectId = Random().nextInt(1000000000).toString();

    await cacheRepository.saveGoogleProjectId(projectId);

    TakeOffFacade takeOffFacade = TakeOffFacade();
    takeOffFacade.googleController = GoogleCloudControllerImpl();

    expect(
        (await takeOffFacade.getProjects(CloudProviderId.gcloud))
            .contains(projectId),
        true);

    Directory directory = Directory(
        join(foldersService.getHostFolders()["workspace"]!, projectId));
    if (directory.existsSync()) {
      fail("Project directory already existed");
    }
    directory.createSync(recursive: true);

    await takeOffFacade.cleanProject(CloudProviderId.gcloud, projectId);

    expect(directory.existsSync(), false);
    expect(
        (await takeOffFacade.getProjects(CloudProviderId.gcloud))
            .contains(projectId),
        false);
  });

  test("LogOut the user", () async {
    TakeOffFacade facade = TakeOffFacade();
    facade.googleController = GoogleCloudControllerImpl();
    String email = "${Random().nextInt(100000000)}@mail.com";
    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.saveGoogleEmail(email);

    // Check that the user is saved
    expect(await facade.getCurrentAccount(CloudProviderId.gcloud), email);
    // If user exists logOut returns true and getting the account returns empty
    expect(await facade.logOut(CloudProviderId.gcloud), true);
    expect(await facade.getCurrentAccount(CloudProviderId.gcloud), "");

    // If user doesn't exist returns false
    expect(await facade.logOut(CloudProviderId.gcloud), false);
  });

  // test('runProject executes properly for google cloud', () async {
  //   CacheRepository cacheRepository = CacheRepositoryImpl();
  //   String email = "${Random().nextInt(100000000)}@mail.com";
  //   String projectId = Random().nextInt(1000000000).toString();

  //   await cacheRepository.saveGoogleEmail(email);
  //   await cacheRepository.saveGoogleProjectId(projectId);

  //   TakeOffFacade facade = TakeOffFacade();

  //   final runProject = await facade.runProject(projectId, CloudProviderId.gcloud);

  //   expect(runProject, true);
  // });

  tearDown(() async {
    GetIt.I.unregister<Database>();
    await databaseFactoryIo.deleteDatabase("facade_test.db");
  });
}
