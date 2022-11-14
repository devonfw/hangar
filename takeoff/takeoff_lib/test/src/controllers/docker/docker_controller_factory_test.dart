import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller_factory.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_installation.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/ddesktop_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/rancher_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/unix_controller.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:takeoff_lib/src/utils/system/system_service.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'docker_controller_factory_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<PlatformService>(),
  MockSpec<FoldersService>(),
  MockSpec<SystemService>()
])
void main() {
  MockFoldersService mockFoldersService = MockFoldersService();

  setUpAll(() {
    GetIt.I.registerSingleton<FoldersService>(mockFoldersService);
  });

  group("DockerController factory with Unix tests", () {
    MockPlatformService mockPlatformService = MockPlatformService();

    setUpAll(() {
      when(mockPlatformService.isUnix).thenReturn(true);
      GetIt.I.registerSingleton<PlatformService>(mockPlatformService);
    });

    test("checkDockerInstallationType is correct", () async {
      DockerControllerFactory factory = DockerControllerFactory();
      expect(
          await factory.checkDockerInstallationType(), DockerInstallation.unix);
    });

    test("create is correct", () async {
      DockerControllerFactory factory = DockerControllerFactory();
      expect(await factory.create() is UnixController, true);
    });

    tearDownAll(() {
      GetIt.I.unregister<PlatformService>();
    });
  });

  group("DockerController factory with Windows & Rancher Desktop tests", () {
    MockPlatformService mockPlatformService = MockPlatformService();
    MockSystemService mockSystemService = MockSystemService();

    setUpAll(() {
      when(mockPlatformService.isWindows).thenReturn(true);
      when(mockSystemService.isDockerDesktopInstalled())
          .thenAnswer((_) async => false);
      GetIt.I.registerSingleton<PlatformService>(mockPlatformService);
    });

    test("checkDockerInstallationType is correct", () async {
      DockerControllerFactory factory =
          DockerControllerFactory(systemService: mockSystemService);
      expect(await factory.checkDockerInstallationType(),
          DockerInstallation.rancherDesktop);
    });

    test("create is correct", () async {
      DockerControllerFactory factory =
          DockerControllerFactory(systemService: mockSystemService);
      expect(await factory.create() is RancherController, true);
    });

    tearDownAll(() {
      GetIt.I.unregister<PlatformService>();
    });
  });

  group("DockerController factory with Windows & Docker Desktop tests", () {
    MockPlatformService mockPlatformService = MockPlatformService();
    MockSystemService mockSystemService = MockSystemService();

    setUpAll(() {
      when(mockPlatformService.isWindows).thenReturn(true);
      when(mockSystemService.isDockerDesktopInstalled())
          .thenAnswer((_) async => true);
      GetIt.I.registerSingleton<PlatformService>(mockPlatformService);
    });

    test("checkDockerInstallationType is correct", () async {
      DockerControllerFactory factory =
          DockerControllerFactory(systemService: mockSystemService);
      expect(await factory.checkDockerInstallationType(),
          DockerInstallation.dockerDesktop);
    });

    test("create is correct", () async {
      DockerControllerFactory factory =
          DockerControllerFactory(systemService: mockSystemService);
      expect(await factory.create() is DockerDesktopController, true);
    });

    tearDownAll(() {
      GetIt.I.unregister<PlatformService>();
    });
  });
}
