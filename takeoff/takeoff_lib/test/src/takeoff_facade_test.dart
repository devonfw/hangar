import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/domain/cloud_provider_id.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_singleton.dart';
import 'package:takeoff_lib/src/takeoff_facade.dart';
import 'package:test/test.dart';

void main() {
  setUp(() async {
    GetIt.I.registerSingleton<Database>(
        await DatabaseSingleton(dbPath: "facade_test.db").initialize());
  });

  test(
      "getCurrentAccount returns empty for Google Cloud if there is no logged account",
      () async {
    TakeOffFacade facade = TakeOffFacade();

    expect(await facade.getCurrentAccount(CloudProviderId.gcloud), "");
  });

  test("getCurrentAccount returns the current stored Google Cloud email",
      () async {
    TakeOffFacade facade = TakeOffFacade();
    String email = "${Random().nextInt(100000000)}@mail.com";
    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.saveGoogleEmail(email);

    expect(await facade.getCurrentAccount(CloudProviderId.gcloud), email);
  });

  test(
      "getProjects returns empty for Google Cloud if there is no created projects",
      () async {
    TakeOffFacade takeOffFacade = TakeOffFacade();

    expect(await takeOffFacade.getProjects(CloudProviderId.gcloud), []);
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

  tearDown(() async {
    GetIt.I.unregister<Database>();
    await databaseFactoryIo.deleteDatabase("facade_test.db");
  });
}
