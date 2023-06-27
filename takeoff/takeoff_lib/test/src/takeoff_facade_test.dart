import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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
import 'package:takeoff_lib/src/domain/gui_message/gui_message.dart';
import 'package:takeoff_lib/src/domain/language.dart';
import 'package:takeoff_lib/src/domain/resource.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_factory.dart';
import 'package:takeoff_lib/src/takeoff_facade.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:test/test.dart';

import 'takeoff_facade_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<DockerController>(),
  MockSpec<AuthController<CloudProvider>>(),
  MockSpec<GoogleCloudController>()
])
void main() {
  MockDockerController mockDockerController = MockDockerController();
  MockGoogleCloudController mockGoogleCloudController =
      MockGoogleCloudController();
  // MockAuthController mockAuthController = MockAuthController();
  late FoldersService foldersService;
  late TakeOffFacade facade;
  late GoogleCloudController googleCloudController;

  setUpAll(() {
    // GetIt.I.registerSingleton<AuthController<CloudProvider>>(mockAuthController);
    GetIt.I.registerSingleton<DockerController>(mockDockerController);
    GetIt.I.registerSingleton(PlatformService());
    foldersService = FoldersService();
    GetIt.I.registerSingleton(foldersService);
    facade = TakeOffFacade();
    googleCloudController = GoogleCloudControllerImpl();
  });

  setUp(() async {
    GetIt.I.registerSingleton<Database>(
        await DbFactory(dbPath: "facade_test.db").create());
    facade.googleController = googleCloudController;
  });

  test(
      "getCurrentAccount returns empty for Google Cloud if there is no logged account",
      () async {
    expect(await facade.getCurrentAccount(CloudProviderId.gcloud), "");
  });

  test("getCurrentAccount returns the current stored Google Cloud email",
      () async {
    String email = "${Random().nextInt(100000000)}@mail.com";
    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.saveGoogleEmail(email);

    expect(await facade.getCurrentAccount(CloudProviderId.gcloud), email);
  });

  test("getCurrentAccount returns empty string for unsupported clouds",
      () async {
    //Not supported
    expect(await facade.getCurrentAccount(CloudProviderId.aws), "");
    expect(await facade.getCurrentAccount(CloudProviderId.azure), "");
  });

  test(
      "getProjects returns empty for Google Cloud if there is no created projects",
      () async {
    facade.googleController = mockGoogleCloudController;

    expect(await facade.getProjects(CloudProviderId.gcloud), []);
  });

  test("getProjects returns the correct Google Cloud projects", () async {
    CacheRepository cacheRepository = CacheRepositoryImpl();

    String email = "${Random().nextInt(100000000)}@mail.com";
    await cacheRepository.saveGoogleEmail(email);

    List<String> projects = List.generate(
        Random().nextInt(15) + 5, (_) => Random().nextInt(1000000).toString());
    for (String elem in projects) {
      await cacheRepository.saveGoogleProjectId(elem);
    }

    expect(projects, await facade.getProjects(CloudProviderId.gcloud));

    //Not supported
    expect(await facade.getProjects(CloudProviderId.aws), []);
    expect(await facade.getProjects(CloudProviderId.azure), []);
  });

  test("Clean project in Google Cloud is correct", () async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String projectId = Random().nextInt(1000000000).toString();

    await cacheRepository.saveGoogleProjectId(projectId);

    expect(
        (await facade.getProjects(CloudProviderId.gcloud)).contains(projectId),
        true);

    Directory directory = Directory(
        join(foldersService.getHostFolders()["workspace"]!, projectId));
    if (directory.existsSync()) {
      fail("Project directory already existed");
    }
    directory.createSync(recursive: true);

    await facade.cleanProject(CloudProviderId.gcloud, projectId);

    expect(directory.existsSync(), false);
    expect(
        (await facade.getProjects(CloudProviderId.gcloud)).contains(projectId),
        false);

    //Not supported
    expect(await facade.cleanProject(CloudProviderId.aws, "project"), false);
    expect(await facade.cleanProject(CloudProviderId.azure, "project"), false);
  });

  test("LogOut the user", () async {
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

    //Currently not supported
    expect(await facade.logOut(CloudProviderId.aws), false);
    expect(await facade.logOut(CloudProviderId.azure), false);
  });

  test("runProject calls the correct methods", () async {
    facade.googleController = mockGoogleCloudController;
    when(mockGoogleCloudController.run(any)).thenAnswer((_) async => true);

    expect(await facade.runProject("id", CloudProviderId.gcloud), true);

    verify(mockGoogleCloudController.run("id")).called(1);

    expect(await facade.runProject("id", CloudProviderId.aws), false);
    expect(await facade.runProject("id", CloudProviderId.azure), false);
  });

  test("init calls the correct methods", () async {
    facade.googleController = mockGoogleCloudController;
    when(mockGoogleCloudController.init(any)).thenAnswer((_) async => true);

    expect(await facade.init("email", CloudProviderId.gcloud), true);

    verify(mockGoogleCloudController.init("email")).called(1);

    expect(await facade.init("email", CloudProviderId.aws), false);
    expect(await facade.init("email", CloudProviderId.azure), false);
  });

  test("createProjectGCloud calls the correct method", () async {
    facade.googleController = mockGoogleCloudController;
    when(mockGoogleCloudController.createProject(
            projectName: anyNamed("projectName"),
            billingAccount: anyNamed("billingAccount"),
            googleCloudRegion: anyNamed("googleCloudRegion"),
            backendLanguage: anyNamed("backendLanguage"),
            frontendLanguage: anyNamed("frontendLanguage"),
            backendVersion: anyNamed("backendVersion"),
            frontendVersion: anyNamed("frontendVersion"),
            outputStream: anyNamed("outputStream"),
            inputStream: anyNamed("inputStream")))
        .thenAnswer((_) async => true);

    StreamController<GuiMessage> outputStream = StreamController();
    StreamController<String> inputStream = StreamController();

    expect(
        await facade.createProjectGCloud(
            projectName: "name",
            billingAccount: "billing",
            googleCloudRegion: "region",
            backendLanguage: Language.node,
            backendVersion: "1",
            frontendLanguage: Language.flutter,
            frontendVersion: "1",
            outputStream: outputStream,
            inputStream: inputStream),
        true);

    verify(mockGoogleCloudController.createProject(
            projectName: "name",
            billingAccount: "billing",
            googleCloudRegion: "region",
            backendLanguage: Language.node,
            backendVersion: "1",
            frontendLanguage: Language.flutter,
            frontendVersion: "1",
            outputStream: outputStream,
            inputStream: inputStream))
        .called(1);
  });

  test("quickstartWayat calls the correct method", () async {
    facade.googleController = mockGoogleCloudController;
    when(mockGoogleCloudController.wayatQuickstart(
            billingAccount: anyNamed("billingAccount"),
            googleCloudRegion: anyNamed("googleCloudRegion"),
            outputStream: anyNamed("outputStream"),
            inputStream: anyNamed("inputStream")))
        .thenAnswer((_) async => true);

    StreamController<GuiMessage> outputStream = StreamController();
    StreamController<String> inputStream = StreamController();

    expect(
        await facade.quickstartWayat(
            billingAccount: "billing",
            googleCloudRegion: "region",
            inputStream: inputStream,
            outputStream: outputStream),
        true);

    verify(mockGoogleCloudController.wayatQuickstart(
            billingAccount: "billing",
            googleCloudRegion: "region",
            inputStream: inputStream,
            outputStream: outputStream))
        .called(1);
  });

  test("getResource calls the right method", () async {
    facade.googleController = mockGoogleCloudController;
    Uri gcloudResUrl = Uri.parse("https://gcloudresourceurl.com");
    Uri emptyUri = Uri.parse("");
    when(mockGoogleCloudController.getGCloudResourceUrl(any, any))
        .thenReturn(gcloudResUrl);

    expect(facade.getResource("project", CloudProviderId.gcloud, Resource.ide),
        gcloudResUrl);

    //Not supported
    expect(facade.getResource("project", CloudProviderId.azure, Resource.ide),
        emptyUri);
    expect(facade.getResource("project", CloudProviderId.aws, Resource.ide),
        emptyUri);
  });

  tearDown(() async {
    GetIt.I.unregister<Database>();
    await databaseFactoryIo.deleteDatabase("facade_test.db");
  });
}
