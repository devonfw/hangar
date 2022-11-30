import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/persistence/database/database_factory.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:test/scaffolding.dart';

void main() {
  setUpAll(() async {
    GetIt.I.registerSingleton(PlatformService());
    GetIt.I.registerSingleton(FoldersService());
    GetIt.I.registerSingleton(await DbFactory().create());
  });
  test("", () async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    cacheRepository.saveGoogleProjectId("takeoff-project-test");
  });
}
