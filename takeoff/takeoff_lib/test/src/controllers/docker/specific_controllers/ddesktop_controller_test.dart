import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/ddesktop_controller.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'ddesktop_controller_test.mocks.dart';

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
    DockerDesktopController controller = DockerDesktopController();
    List<String> expectedMappings = [
      "-v",
      "C:\\Users\\user\\AppData\\Roaming\\gcloud:/root/.config/gcloud",
      "-v",
      "C:\\Users\\user\\.aws:/root/.aws",
      "-v",
      "C:\\Users\\user\\.azure:/root/.azure",
      "-v",
      "C:\\Users\\user\\.kube:/root/.kube",
      "-v",
      "C:\\Users\\user\\AppData\\Roaming\\GitHub CLI:/root/.config/gh",
      "-v",
      "C:\\Users\\user\\.ssh:/root/.ssh",
    ];

    expect(controller.getVolumeMappings(), expectedMappings);
  });
}