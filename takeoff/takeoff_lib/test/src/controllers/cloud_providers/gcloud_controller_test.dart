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
    int random = Random().nextInt(99);
    String projectId = "wayat-takeoff-$random-$random-$random-$random-$random";
    RegExp rule = RegExp(
        r'wayat-takeoff-(\d{1,2})-(\d{1,2})-(\d{1,2})-(\d{1,2})-(\d{1,4})');

    expect(rule.hasMatch(projectId), true);
  });

  test("Get resource Url for quickstart projects", () {
    int random = Random().nextInt(99);
    String projectId = "wayat-takeoff-$random-$random-$random-$random-$random";
    GoogleCloudControllerImpl googleCloudController =
        GoogleCloudControllerImpl();

    Uri ideUrl =
        googleCloudController.getGCloudResourceUrl(projectId, Resource.ide);
    Uri expectIdeUrl = Uri.parse(
        "https://console.cloud.google.com/cloudshelleditor?project=$projectId&cloudshell=true");
    expect(ideUrl, expectIdeUrl);

    Uri pipelineUrl = googleCloudController.getGCloudResourceUrl(
        projectId, Resource.pipeline);
    Uri expectPipelineUrl = Uri.parse(
        "https://console.cloud.google.com/cloud-build/dashboard?project=$projectId");
    expect(pipelineUrl, expectPipelineUrl);

    Uri feRepoUrl =
        googleCloudController.getGCloudResourceUrl(projectId, Resource.feRepo);
    Uri expectFeRepoUrl =
        Uri.parse("https://source.cloud.google.com/$projectId/wayat-flutter/");
    expect(feRepoUrl, expectFeRepoUrl);

    Uri beRepoUrl =
        googleCloudController.getGCloudResourceUrl(projectId, Resource.beRepo);
    Uri expectBeRepoUrl =
        Uri.parse("https://source.cloud.google.com/$projectId/wayat-python/");
    expect(beRepoUrl, expectBeRepoUrl);

    Uri resourceNone =
        googleCloudController.getGCloudResourceUrl(projectId, Resource.none);
    expect(resourceNone, Uri.parse(""));
  });

  test("Get resource Url for created projects", () {
    String projectId = "wayat-takeoff";
    GoogleCloudControllerImpl googleCloudController =
        GoogleCloudControllerImpl();

    Uri ideUrl =
        googleCloudController.getGCloudResourceUrl(projectId, Resource.ide);
    Uri expectIdeUrl = Uri.parse(
        "https://console.cloud.google.com/cloudshelleditor?project=$projectId&cloudshell=true");
    expect(ideUrl, expectIdeUrl);

    Uri pipelineUrl = googleCloudController.getGCloudResourceUrl(
        projectId, Resource.pipeline);
    Uri expectPipelineUrl = Uri.parse(
        "https://console.cloud.google.com/cloud-build/dashboard?project=$projectId");
    expect(pipelineUrl, expectPipelineUrl);

    Uri feRepoUrl =
        googleCloudController.getGCloudResourceUrl(projectId, Resource.feRepo);
    Uri expectFeRepoUrl =
        Uri.parse("https://source.cloud.google.com/$projectId/Frontend/");
    expect(feRepoUrl, expectFeRepoUrl);

    Uri beRepoUrl =
        googleCloudController.getGCloudResourceUrl(projectId, Resource.beRepo);
    Uri expectBeRepoUrl =
        Uri.parse("https://source.cloud.google.com/$projectId/Backend/");
    expect(beRepoUrl, expectBeRepoUrl);

    Uri resourceNone =
        googleCloudController.getGCloudResourceUrl(projectId, Resource.none);
    expect(resourceNone, Uri.parse(""));
  });
}
