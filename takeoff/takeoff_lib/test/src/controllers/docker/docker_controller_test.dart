import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/unix_controller.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/system/system_service.dart';
import 'package:test/test.dart';

import 'docker_controller_factory_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SystemService>(), MockSpec<FoldersService>()])
void main() {
  MockSystemService mockSystemService = MockSystemService();
  MockFoldersService mockFoldersService = MockFoldersService();

  setUpAll(() {
    GetIt.I.registerSingleton<FoldersService>(mockFoldersService);
  });

  test("checkDockerInstallation returns false if docker is not installed", () {
    when(mockSystemService.isDockerInstalled()).thenReturn(false);

    DockerController dockerController =
        UnixController(systemService: mockSystemService);

    expect(dockerController.checkDockerInstallation(), false);
  });

  test("checkDockerInstallation returns false if docker is not running", () {
    when(mockSystemService.isDockerInstalled()).thenReturn(true);
    when(mockSystemService.isDockerRunning()).thenReturn(false);

    DockerController dockerController =
        UnixController(systemService: mockSystemService);

    expect(dockerController.checkDockerInstallation(), false);
  });

  test("checkDockerInstallation returns true if Docker is installed & running",
      () {
    when(mockSystemService.isDockerInstalled()).thenReturn(true);
    when(mockSystemService.isDockerRunning()).thenReturn(true);

    DockerController dockerController =
        UnixController(systemService: mockSystemService);

    expect(dockerController.checkDockerInstallation(), true);
  });

  test("Docker execute command is built correctly", () {
    DockerController dockerController = UnixController();
    when(mockFoldersService.getHostFolders()).thenReturn(
      {
        "gcloud": "/folder/gcloud",
        "aws": "/folder/aws",
        "azure": "/folder/azure",
        "kube": "/folder/kube",
        "github": "/folder/github",
        "ssh": "/folder/ssh",
      },
    );

    expect(dockerController.buildCommands(["-d", "-p"], ["bash"]), [
      "run",
      "--rm",
      "-d",
      "-p",
      "-v",
      "/folder/gcloud:/root/.config/gcloud",
      "-v",
      "/folder/aws:/root/.aws",
      "-v",
      "/folder/azure:/root/.azure",
      "-v",
      "/folder/kube:/root/.kube",
      "-v",
      "/folder/github:/root/.config/gh",
      "-v",
      "/folder/ssh:/root/.ssh",
      "hangar",
      "bash"
    ]);
  });
}
