import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_singleton.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  setUp(() async {
    GetIt.I.registerSingleton<Database>(
        await DatabaseSingleton(dbPath: "test.db").initialize());
  });

  test("saveGoogleEmail & getGoogleEmail are correct", () async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.saveGoogleEmail("google_email@gmail.com");
    expect(await cacheRepository.getGoogleEmail(), "google_email@gmail.com");
    await cacheRepository.saveGoogleEmail("another@gmail.com");
    expect(await cacheRepository.getGoogleEmail() == "google_email@gmail.com",
        false);
  });

  test("saveGoogleProjectId & getGoogleProjectIds are correct", () async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String email = "mail@mail.com";
    await cacheRepository.saveGoogleEmail(email);

    String projectId1 = "${Random()}_project";
    String projectId2 = "${Random()}_project";
    String projectId3 = "${Random()}_project";
    await cacheRepository.saveGoogleProjectId(projectId1);
    await cacheRepository.saveGoogleProjectId(projectId2);
    await cacheRepository.saveGoogleProjectId(projectId3);

    expect(await cacheRepository.getGoogleProjectIds(),
        [projectId1, projectId2, projectId3]);
  });

  tearDown(() {
    databaseFactoryIo.deleteDatabase("test.db");
    GetIt.I.unregister<Database>();
  });
}
