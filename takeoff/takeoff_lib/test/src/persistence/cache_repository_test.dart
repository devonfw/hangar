import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_singleton.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  setUpAll(() async {
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

  tearDownAll(() {
    databaseFactoryIo.deleteDatabase("test.db");
  });
}
