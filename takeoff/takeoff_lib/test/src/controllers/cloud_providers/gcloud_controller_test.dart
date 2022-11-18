import 'dart:io';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_lib/src/controllers/cloud_providers/gcloud_controller.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_singleton.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
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
        await DatabaseSingleton(dbPath: "gcloud_controller_test.db")
            .initialize());
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

    GoogleCloudController googleCloudController = GoogleCloudController();
    await googleCloudController.cleanProject(projectId);

    expect(directory.existsSync(), false);
    expect((await cacheRepository.getGoogleProjectIds()).contains(projectId),
        false);
  });

  tearDown(() async {
    await databaseFactoryIo.deleteDatabase("gcloud_controller_test.db");
    GetIt.I.unregister<Database>();
  });
}
