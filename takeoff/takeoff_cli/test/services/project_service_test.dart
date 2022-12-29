import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/persistence/database/database_factory.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/gcloud_controller_impl.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import 'package:test/test.dart';
import 'package:path/path.dart';

import 'project_service_test.mocks.dart';

List<String> log = [];

@GenerateNiceMocks([MockSpec<TakeOffFacade>(), MockSpec<UrlLaucher>()])
void main() {
  late FoldersService foldersService;
  TakeOffFacade facade = TakeOffFacade();

  setUpAll(() async {
    GetIt.I.registerSingleton(PlatformService());
    foldersService = FoldersService();
    GetIt.I.registerSingleton(foldersService);
    facade.googleController = GoogleCloudControllerImpl();
    await databaseFactoryIo.deleteDatabase("project_service_test.db");
  });

  setUp(() async {
    log.clear();
    GetIt.I.registerSingleton<Database>(
        await DbFactory(dbPath: "project_service_test.db").create());
  });

  test(
      "listProjects prints the correct message if not logged with Google Cloud",
      overridePrint(() async {
    ProjectsService projectsService = ProjectsService(facade);
    await projectsService.listProjects(CloudProviderId.gcloud);

    expect(log.length, 1);
    expect(
        log.first.contains("You have not logged in with Google Cloud"), true);
  }));

  test(
      "listProjects prints the correct message if no projects are created with Google Cloud",
      overridePrint(() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String email = "test${Random().nextInt(10000)}@mail.com";
    await cacheRepository.saveGoogleEmail(email);
    ProjectsService projectsService = ProjectsService(facade);
    await projectsService.listProjects(CloudProviderId.gcloud);

    expect(log.length, 1);
    expect(log.first.contains("No projects created with Google Cloud"), true);
  }));

  test(
      "listProjects prints the correct messages if there are projects created with Google Cloud",
      overridePrint(() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String email = "test${Random().nextInt(10000)}@mail.com}";
    await cacheRepository.saveGoogleEmail(email);

    List<String> projects =
        List.generate(15, (_) => Random().nextInt(1000000).toString());
    for (String elem in projects) {
      await cacheRepository.saveGoogleProjectId(elem);
    }

    ProjectsService projectsService = ProjectsService(facade);

    await projectsService.listProjects(CloudProviderId.gcloud);

    expect(log.length, 16);
    expect(log.first.contains("Projects from Google Cloud:"), true);
    expect(log.sublist(1), projects);
  }));

  test(
      "cleanProject prints the correct message if the project does not exist with Google Cloud",
      overridePrint(() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String email = "test${Random().nextInt(10000)}@mail.com}";
    await cacheRepository.saveGoogleEmail(email);

    ProjectsService projectsService = ProjectsService(facade);
    await projectsService.cleanProject(CloudProviderId.gcloud, "projectId");

    expect(log.length, 1);
    expect(
        log.first.contains(
            "Project projectId does not exist in TakeOff for Google Cloud"),
        true);
  }));

  test(
      "cleanProject prints the correct message if the project does not exist with Google Cloud",
      overridePrint(() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String email = "test${Random().nextInt(10000)}@mail.com}";
    await cacheRepository.saveGoogleEmail(email);

    List<String> projects =
        List.generate(15, (_) => Random().nextInt(1000000).toString());
    for (String elem in projects) {
      await cacheRepository.saveGoogleProjectId(elem);
    }

    ProjectsService projectsService = ProjectsService(facade);
    await projectsService.cleanProject(CloudProviderId.gcloud, "projectId");

    expect(log.length, 1);
    expect(
        log.first.contains(
            "Project projectId does not exist in TakeOff for Google Cloud"),
        true);
  }));

  test(
      "cleanProject prints the correct message if the project exist with Google Cloud",
      overridePrint(() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String email = "test${Random().nextInt(10000)}@mail.com}";
    await cacheRepository.saveGoogleEmail(email);

    List<String> projects =
        List.generate(15, (_) => Random().nextInt(1000000).toString());
    for (String elem in projects) {
      await cacheRepository.saveGoogleProjectId(elem);
    }
    await cacheRepository.saveGoogleProjectId("projectId");

    ProjectsService projectsService = ProjectsService(facade);
    await projectsService.cleanProject(CloudProviderId.gcloud, "projectId");

    expect(log.length, 1);
    expect(log.first.contains("Cleaned all data from project projectId"), true);
  }));

  test("cleanProject cleans the data", overridePrint(() async {
    String project = "project_${Random().nextInt(100000)}";

    Directory directory =
        Directory(join(foldersService.getHostFolders()["workspace"]!, project));
    if (directory.existsSync()) {
      fail("Project directory $project already existed");
    }
    directory.createSync();

    CacheRepository cacheRepository = CacheRepositoryImpl();
    String email = "test${Random().nextInt(10000)}@mail.com}";
    await cacheRepository.saveGoogleEmail(email);

    List<String> projects =
        List.generate(15, (_) => Random().nextInt(1000000).toString());
    for (String elem in projects) {
      await cacheRepository.saveGoogleProjectId(elem);
    }
    await cacheRepository.saveGoogleProjectId(project);

    ProjectsService projectsService = ProjectsService(facade);
    await projectsService.cleanProject(CloudProviderId.gcloud, project);

    expect(log.length, 1);
    expect(log.first.contains("Cleaned all data from project $project"), true);
    expect(
        (await cacheRepository.getGoogleProjectIds()).contains(project), false);
    expect(directory.existsSync(), false);
  }));

  test("runProject calls the correct method in the facade", () async {
    MockTakeOffFacade mockTakeOffFacade = MockTakeOffFacade();
    ProjectsService projectsService = ProjectsService(mockTakeOffFacade);

    String project = "project_${Random().nextInt(100000)}";
    int providerIndex = Random().nextInt(3);
    List<CloudProviderId> cloudProvider = [
      CloudProviderId.aws,
      CloudProviderId.azure,
      CloudProviderId.gcloud
    ];

    await projectsService.runProject(project, cloudProvider[providerIndex]);

    verify(mockTakeOffFacade.runProject(project, cloudProvider[providerIndex]))
        .called(1);
  });

  test("createGoogleProject calls the correct method in the facade", () async {
    MockTakeOffFacade mockTakeOffFacade = MockTakeOffFacade();
    ProjectsService projectsService = ProjectsService(mockTakeOffFacade);

    String project = "project_${Random().nextInt(100000)}";

    await projectsService.createGoogleProject(
        projectName: project,
        billingAccount: "billing",
        backendLanguage: Language.node,
        backendVersion: "1",
        frontendLanguage: Language.flutter,
        frontendVersion: "2",
        googleCloudRegion: googleCloudRegions.first);

    verify(mockTakeOffFacade.createProjectGCloud(
            projectName: project,
            billingAccount: "billing",
            backendLanguage: Language.node,
            backendVersion: "1",
            frontendLanguage: Language.flutter,
            frontendVersion: "2",
            googleCloudRegion: googleCloudRegions.first))
        .called(1);
  });

  test("createGoogleProject logs an error if it fails", overridePrint(() async {
    MockTakeOffFacade mockTakeOffFacade = MockTakeOffFacade();
    ProjectsService projectsService = ProjectsService(mockTakeOffFacade);

    String project = "project_${Random().nextInt(100000)}";

    when(mockTakeOffFacade.createProjectGCloud(
            projectName: anyNamed("projectName"),
            billingAccount: anyNamed("billingAccount"),
            googleCloudRegion: anyNamed("googleCloudRegion"),
            backendLanguage: anyNamed("backendLanguage"),
            backendVersion: anyNamed("backendVersion"),
            frontendLanguage: anyNamed("frontendLanguage"),
            frontendVersion: anyNamed("frontendVersion")))
        .thenThrow(CreateProjectException("Error creating project $project"));

    await projectsService.createGoogleProject(
        projectName: project,
        billingAccount: "billing",
        backendLanguage: Language.node,
        backendVersion: "1",
        frontendLanguage: Language.flutter,
        frontendVersion: "2",
        googleCloudRegion: googleCloudRegions.first);

    expect(log.length, 1);
    expect(log.first.contains("Error creating project $project"), true);
  }));

  test("quickstartWayat calls the correct method in the facade", () async {
    MockTakeOffFacade mockTakeOffFacade = MockTakeOffFacade();
    ProjectsService projectsService = ProjectsService(mockTakeOffFacade);

    String billingAccount = "${Random().nextInt(100000)}";

    await projectsService.quickstartWayat(
        billingAccount: billingAccount,
        googleCloudRegion: googleCloudRegions.first);

    verify(mockTakeOffFacade.quickstartWayat(
            billingAccount: billingAccount,
            googleCloudRegion: googleCloudRegions.first))
        .called(1);
  });

  test("quickstartWayat logs an error if it fails", overridePrint(() async {
    MockTakeOffFacade mockTakeOffFacade = MockTakeOffFacade();
    ProjectsService projectsService = ProjectsService(mockTakeOffFacade);

    String billingAccount = "${Random().nextInt(100000)}";

    when(mockTakeOffFacade.quickstartWayat(
            billingAccount: anyNamed("billingAccount"),
            googleCloudRegion: anyNamed("googleCloudRegion")))
        .thenThrow(CreateProjectException(
            "Error quickstarting wayat billing: $billingAccount"));

    await projectsService.quickstartWayat(
        billingAccount: billingAccount,
        googleCloudRegion: googleCloudRegions.first);

    expect(log.length, 1);
    expect(
        log.first
            .contains("Error quickstarting wayat billing: $billingAccount"),
        true);
  }));

  test("openResouce throws an error if not logged in", overridePrint(() async {
    ProjectsService projectsService = ProjectsService(facade);

    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.removeGoogleEmail();

    String project = "project_${Random().nextInt(100000)}";
    int resourceIndex = Random().nextInt(Resource.values.length);
    String googleCloudName = CloudProvider.fromId(CloudProviderId.gcloud).name;

    await projectsService.openResource(
        projectId: project,
        cloudProviderId: CloudProviderId.gcloud,
        resource: Resource.values[resourceIndex]);
    String logg = log.first;

    expect(log.length, 1);
    expect(log.first.contains("You have not logged in with $googleCloudName"),
        true);
  }));

  test("openResouce throws an error if the ID is empty",
      overridePrint(() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String email = "test${Random().nextInt(10000)}@mail.com}";
    await cacheRepository.saveGoogleEmail(email);

    ProjectsService projectsService = ProjectsService(facade);

    int resourceIndex = Random().nextInt(Resource.values.length);

    await projectsService.openResource(
        projectId: "",
        cloudProviderId: CloudProviderId.gcloud,
        resource: Resource.values[resourceIndex]);

    expect(log.length, 1);
    expect(log.first.contains("Project ID cannot be empty"), true);
  }));

  test("openResouce throws an error if the project does not exist",
      overridePrint(() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String email = "test${Random().nextInt(10000)}@mail.com}";
    await cacheRepository.saveGoogleEmail(email);

    ProjectsService projectsService = ProjectsService(facade);

    String project = "project_${Random().nextInt(100000)}";
    int resourceIndex = Random().nextInt(Resource.values.length);
    String googleCloudName = CloudProvider.fromId(CloudProviderId.gcloud).name;

    await projectsService.openResource(
        projectId: project,
        cloudProviderId: CloudProviderId.gcloud,
        resource: Resource.values[resourceIndex]);

    expect(log.length, 1);
    expect(
        log.first.contains(
            "Project $project does not exist in TakeOff for $googleCloudName"),
        true);
  }));

  test("openResouce calls the correct method in the facade", () async {
    MockUrlLaucher mockUrlLaucher = MockUrlLaucher();
    when(mockUrlLaucher.launch(any))
        .thenAnswer((_) async => ProcessResult(1, 0, "", ""));

    String email = "test${Random().nextInt(10000)}@mail.com}";
    String project = "project_${Random().nextInt(100000)}";

    MockTakeOffFacade mockTakeOffFacade = MockTakeOffFacade();
    when(mockTakeOffFacade.getCurrentAccount(any))
        .thenAnswer((_) async => email);
    when(mockTakeOffFacade.getProjects(any)).thenAnswer((_) async => [project]);

    ProjectsService projectsService = ProjectsService(mockTakeOffFacade);

    int resourceIndex = Random().nextInt(Resource.values.length);

    await projectsService.openResource(
        projectId: project,
        cloudProviderId: CloudProviderId.gcloud,
        resource: Resource.values[resourceIndex],
        urlLaucher: mockUrlLaucher);

    verify(mockTakeOffFacade.getResource(
            project, CloudProviderId.gcloud, Resource.values[resourceIndex]))
        .called(1);
    verify(mockUrlLaucher.launch(any)).called(1);
  });

  test("openResouce logs an error if it cannot get the resource",
      overridePrint(() async {
    String email = "test${Random().nextInt(10000)}@mail.com}";
    String project = "project_${Random().nextInt(100000)}";

    MockTakeOffFacade mockTakeOffFacade = MockTakeOffFacade();
    when(mockTakeOffFacade.getCurrentAccount(any))
        .thenAnswer((_) async => email);
    when(mockTakeOffFacade.getProjects(any)).thenAnswer((_) async => [project]);
    when(mockTakeOffFacade.getResource(any, any, any)).thenThrow(Exception(e));

    ProjectsService projectsService = ProjectsService(mockTakeOffFacade);

    int resourceIndex = Random().nextInt(Resource.values.length);

    await projectsService.openResource(
      projectId: project,
      cloudProviderId: CloudProviderId.gcloud,
      resource: Resource.values[resourceIndex],
    );

    expect(log.length, 1);
    expect(
        log.first.contains(
            "Error opening resource ${Resource.values[resourceIndex].name} of project $project"),
        true);
  }));

  test("initAccount calls the correct method in the facade", () async {
    String email = "test${Random().nextInt(10000)}@mail.com}";

    MockTakeOffFacade mockTakeOffFacade = MockTakeOffFacade();

    ProjectsService projectsService = ProjectsService(mockTakeOffFacade);

    await projectsService.initAccount(CloudProviderId.gcloud, email);

    verify(mockTakeOffFacade.init(email, CloudProviderId.gcloud,
            useStdin: true))
        .called(1);
  });

  tearDown(() async {
    await GetIt.I.unregister<Database>();
    await databaseFactoryIo.deleteDatabase("project_service_test.db");
  });
}

void Function() overridePrint(void Function() testFn) => () {
      var spec = ZoneSpecification(print: (_, __, ___, String msg) {
        // Add to log instead of printing to stdout
        log.add(msg);
      });
      return Zone.current.fork(specification: spec).run<void>(testFn);
    };
