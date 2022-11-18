import 'dart:async';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/persistence/database/database_singleton.dart';
import 'package:takeoff_lib/src/persistence/cache_repository_impl.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import 'package:test/test.dart';

List<String> log = [];

void main() {
  late FoldersService foldersService;

  setUpAll(() {
    GetIt.I.registerSingleton(PlatformService());
    foldersService = FoldersService();
    GetIt.I.registerSingleton(foldersService);
  });

  setUp(() async {
    log.clear();
    GetIt.I.registerSingleton<Database>(
        await DatabaseSingleton(dbPath: "project_service_test.db")
            .initialize());
  });

  test(
      "listProjects prints the correct message if not logged with Google Cloud",
      overridePrint(() async {
    ProjectsService projectsService = ProjectsService(TakeOffFacade());
    await projectsService.listProjects("gc");

    expect(log.length, 1);
    expect(
        log.first.contains("You have not logged in with Google Cloud"), true);
  }));

  test(
      "listProjects prints the correct message if no projects are created with Google Cloud",
      overridePrint(() async {
    CacheRepository cacheRepository = CacheRepositoryImpl();
    String email = "test${Random().nextInt(10000)}@mail.com}";
    await cacheRepository.saveGoogleEmail(email);
    ProjectsService projectsService = ProjectsService(TakeOffFacade());
    await projectsService.listProjects("gc");

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

    ProjectsService projectsService = ProjectsService(TakeOffFacade());

    await projectsService.listProjects("gc");

    expect(log.length, 16);
    expect(log.first.contains("Projects from Google Cloud:"), true);
    expect(log.sublist(1), projects);
  }));

  tearDown(() async {
    GetIt.I.unregister<Database>();
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
