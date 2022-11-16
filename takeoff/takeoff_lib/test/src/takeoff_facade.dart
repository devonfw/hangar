import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/domain/cloud_provider_enum.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_singleton.dart';
import 'package:takeoff_lib/src/takeoff_facade.dart';
import 'package:test/test.dart';

void main() {
  setUp(() async {
    GetIt.I.registerSingleton<Database>(
        await DatabaseSingleton(dbPath: "test.db").initialize());
  });

  test(
      "getCurrentAccount returns empty for GCloud if there is no logged account",
      () async {
    TakeOffFacade facade = TakeOffFacade();

    expect(await facade.getCurrentAccount(CloudProviderId.gcloud), "");
  });

  test("getCurrentAccount returns the current stored GCloud email", () async {
    TakeOffFacade facade = TakeOffFacade();
    String email = "${Random().nextInt(100000000)}@mail.com";
    print(email);
    CacheRepository cacheRepository = CacheRepositoryImpl();
    await cacheRepository.saveGoogleEmail(email);

    expect(await facade.getCurrentAccount(CloudProviderId.gcloud), email);
  });

  tearDown(() {
    GetIt.I.unregister<Database>();
    databaseFactoryIo.deleteDatabase("test.db");
  });
}
