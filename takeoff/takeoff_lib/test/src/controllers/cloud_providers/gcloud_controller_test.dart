import 'dart:io';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_lib/src/controllers/cloud/gcloud/gcloud_controller_impl.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_factory.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late FoldersService foldersService;

  setUpAll(() {
    GetIt.I.registerSingleton<PlatformService>(PlatformService());
    foldersService = FoldersService();
    GetIt.I.registerSingleton<FoldersService>(foldersService);
  });

  setUp(() async {
    GetIt.I.registerSingleton<Database>(
        await DbFactory(dbPath: "gcloud_controller_test.db").create());
  });

  test("cleanProject removes the workspace folder and the project ID",
      () async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String projectId = Random().nextInt(1000000000).toString();
    await cacheRepository.saveGoogleProjectId(projectId);
    Directory directory = Directory(
        join(foldersService.getHostFolders()["workspace"]!, projectId));
    if (directory.existsSync()) {
      fail("Project directory already existed");
    }
    directory.createSync(recursive: true);

    GoogleCloudControllerImpl googleCloudController =
        GoogleCloudControllerImpl();
    await googleCloudController.cleanProject(projectId);

    expect(directory.existsSync(), false);
    expect((await cacheRepository.getGoogleProjectIds()).contains(projectId),
        false);
  });

  tearDown(() async {
    await databaseFactoryIo.deleteDatabase("gcloud_controller_test.db");
    GetIt.I.unregister<Database>();
  });

  test("RegExp match projectId", () {
    GoogleCloudControllerImpl googleCloudController =
        GoogleCloudControllerImpl();

    String projectId_01 = "wayat-takeoff-1-1-1-2-2000";
    String projectId_02 = "wayat-takeoff-1-12-1-12-2000";
    String projectId_03 = "wayat-takeoff-11-12-11-22-2000";
    String projectId_04 = "wayat-takeoff";
    String projectId_05 = "test-wayat";

    expect(googleCloudController.isQuickStartProject(projectId_01), true);
    expect(googleCloudController.isQuickStartProject(projectId_02), true);
    expect(googleCloudController.isQuickStartProject(projectId_03), true);
    expect(googleCloudController.isQuickStartProject(projectId_04), false);
    expect(googleCloudController.isQuickStartProject(projectId_05), false);
  });

  test("Get resource Url for quickstart projects", () {
    GoogleCloudControllerImpl googleCloudController =
        GoogleCloudControllerImpl();

    String projectId_01 = "wayat-takeoff-1-1-1-2-2000";
    String projectId_02 = "wayat-takeoff-1-12-1-12-2000";
    String projectId_03 = "wayat-takeoff-11-12-11-22-2000";
    String projectId_04 = "wayat-takeoff-31-72-21-55-2022";

    Uri ideUrl =
        googleCloudController.getGCloudResourceUrl(projectId_01, Resource.ide);
    Uri expectIdeUrl = Uri.parse(
        "https://console.cloud.google.com/cloudshelleditor?project=$projectId_01&cloudshell=true");
    expect(ideUrl, expectIdeUrl);

    Uri pipelineUrl = googleCloudController.getGCloudResourceUrl(
        projectId_02, Resource.pipeline);
    Uri expectPipelineUrl = Uri.parse(
        "https://console.cloud.google.com/cloud-build/dashboard?project=$projectId_02");
    expect(pipelineUrl, expectPipelineUrl);

    Uri feRepoUrl = googleCloudController.getGCloudResourceUrl(
        projectId_03, Resource.feRepo);
    Uri expectFeRepoUrl = Uri.parse(
        "https://source.cloud.google.com/$projectId_03/wayat-flutter/");
    expect(feRepoUrl, expectFeRepoUrl);

    Uri beRepoUrl = googleCloudController.getGCloudResourceUrl(
        projectId_04, Resource.beRepo);
    Uri expectBeRepoUrl = Uri.parse(
        "https://source.cloud.google.com/$projectId_04/wayat-python/");
    expect(beRepoUrl, expectBeRepoUrl);

    Uri resourceNone =
        googleCloudController.getGCloudResourceUrl(projectId_01, Resource.none);
    expect(resourceNone, Uri.parse(""));
  });

  test("Get resource Url for created projects", () {
    GoogleCloudControllerImpl googleCloudController =
        GoogleCloudControllerImpl();

    String projectId_01 = "wayat-takeoff-12--11-23-2000";
    String projectId_02 = "wayat-takeoff-1-12-1---";
    String projectId_03 = "wayat-takeoff----";
    String projectId_04 = "wayat-takeoff";

    Uri ideUrl =
        googleCloudController.getGCloudResourceUrl(projectId_01, Resource.ide);
    Uri expectIdeUrl = Uri.parse(
        "https://console.cloud.google.com/cloudshelleditor?project=$projectId_01&cloudshell=true");
    expect(ideUrl, expectIdeUrl);

    Uri pipelineUrl = googleCloudController.getGCloudResourceUrl(
        projectId_02, Resource.pipeline);
    Uri expectPipelineUrl = Uri.parse(
        "https://console.cloud.google.com/cloud-build/dashboard?project=$projectId_02");
    expect(pipelineUrl, expectPipelineUrl);

    Uri feRepoUrl = googleCloudController.getGCloudResourceUrl(
        projectId_03, Resource.feRepo);
    Uri expectFeRepoUrl =
        Uri.parse("https://source.cloud.google.com/$projectId_03/Frontend/");
    expect(feRepoUrl, expectFeRepoUrl);

    Uri beRepoUrl = googleCloudController.getGCloudResourceUrl(
        projectId_04, Resource.beRepo);
    Uri expectBeRepoUrl =
        Uri.parse("https://source.cloud.google.com/$projectId_04/Backend/");
    expect(beRepoUrl, expectBeRepoUrl);

    Uri resourceNone =
        googleCloudController.getGCloudResourceUrl(projectId_01, Resource.none);
    expect(resourceNone, Uri.parse(""));
  });
}
