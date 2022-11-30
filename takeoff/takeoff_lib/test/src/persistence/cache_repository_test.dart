import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_factory.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  setUp(() async {
    GetIt.I.registerSingleton<Database>(
        await DbFactory(dbPath: "cache_repo_test.db").create());
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

    List<String> projects = List.generate(
        Random().nextInt(15) + 5, (_) => Random().nextInt(1000000).toString());
    for (String elem in projects) {
      await cacheRepository.saveGoogleProjectId(elem);
    }

    expect(await cacheRepository.getGoogleProjectIds(), projects);
  });

  test("removeGoogleProject is correct", () async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String projectId = Random().nextInt(1000000000).toString();
    await cacheRepository.saveGoogleProjectId(projectId);

    expect((await cacheRepository.getGoogleProjectIds()).contains(projectId),
        true);

    await cacheRepository.removeGoogleProject(projectId);

    expect((await cacheRepository.getGoogleProjectIds()).contains(projectId),
        false);
  });

  tearDown(() async {
    await databaseFactoryIo.deleteDatabase("cache_repo_test.db");
    GetIt.I.unregister<Database>();
  });
}
