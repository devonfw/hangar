import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/rancher_controller.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'rancher_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<PlatformService>()])
void main() {
  MockPlatformService mockPlatformService = MockPlatformService();
  setUpAll(() {
    when(mockPlatformService.env)
        .thenReturn({"UserProfile": "C:\\Users\\user"});
    when(mockPlatformService.isWindows).thenReturn(true);

    GetIt.I.registerSingleton<PlatformService>(mockPlatformService);
    GetIt.I.registerSingleton<FoldersService>(FoldersService());
  });

  test("Volume mappings are correct", () {
    RancherController controller = RancherController(command: "docker");
    List<String> expectedMappings = [
      "-v",
      "/c/Users/user/AppData/Roaming/gcloud:/root/.config/gcloud",
      "-v",
      "/c/Users/user/.aws:/root/.aws",
      "-v",
      "/c/Users/user/.azure:/root/.azure",
      "-v",
      "/c/Users/user/.kube:/root/.kube",
      "-v",
      "/c/Users/user/AppData/Roaming/GitHub CLI:/root/.config/gh",
      "-v",
      "/c/Users/user/.ssh:/root/.ssh",
      "-v",
      "/c/Users/user/hangar_workspace:/scripts/workspace",
      "-v",
      "/c/Users/user/AppData/Roaming/configstore:/root/.config/configstore",
      "-v",
      "/c/Users/user/.gitconfig:/root/.gitconfig",
    ];

    expect(controller.getVolumeMappings(), expectedMappings);
  });
}
