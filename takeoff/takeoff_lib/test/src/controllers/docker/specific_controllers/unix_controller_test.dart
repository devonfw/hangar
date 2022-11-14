import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_lib/src/controllers/docker/specific_controllers/unix_controller.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'unix_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<PlatformService>()])
void main() {
  MockPlatformService mockPlatformService = MockPlatformService();
  setUpAll(() {
    when(mockPlatformService.env).thenReturn({"HOME": "/home/user"});
    when(mockPlatformService.isUnix).thenReturn(true);

    GetIt.I.registerSingleton<PlatformService>(mockPlatformService);
    GetIt.I.registerSingleton<FoldersService>(FoldersService());
  });

  test("Volume mappings are correct", () {
    UnixController controller = UnixController();
    List<String> expectedMappings = [
      "-v",
      "/home/user/.config/gcloud:/root/.config/gcloud",
      "-v",
      "/home/user/.aws:/root/.aws",
      "-v",
      "/home/user/.azure:/root/.azure",
      "-v",
      "/home/user/.kube:/root/.kube",
      "-v",
      "/home/user/.config/gh:/root/.config/gh",
      "-v",
      "/home/user/.ssh:/root/.ssh",
    ];

    expect(controller.getVolumeMappings(), expectedMappings);
  });
}
