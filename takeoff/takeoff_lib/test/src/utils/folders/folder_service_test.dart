import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:takeoff_lib/src/utils/platform/unsupported_platform_exception.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'folder_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<PlatformService>()])
void main() {
  MockPlatformService mockPlatformService = MockPlatformService();
  setUpAll(() {
    when(mockPlatformService.env)
        .thenReturn({"UserProfile": "C:\\Users\\user", "HOME": "/home/user"});

    GetIt.I.registerSingleton<PlatformService>(mockPlatformService);
  });

  group("Unix FoldersService tests", () {
    setUpAll(() {
      when(mockPlatformService.isUnix).thenReturn(true);
    });

    test("Get cache folder path is correct", () {
      Directory cacheFolder = Directory("/home/user/.takeoff/");

      FoldersService foldersService = FoldersService();
      expect(foldersService.getCacheFolderPath(), cacheFolder.path);
    });

    test("Host folders are generated correctly", () {
      Map<String, String> linuxResult = {
        "gcloud": "/home/user/.config/gcloud",
        "aws": "/home/user/.aws",
        "azure": "/home/user/.azure",
        "kube": "/home/user/.kube",
        "github": "/home/user/.config/gh",
        "ssh": "/home/user/.ssh",
        "workspace": "/home/user/hangar_workspace",
        "firebase": "/home/user/.config/configstore",
        "git": "/home/user/.gitconfig"
      };

      FoldersService foldersService = FoldersService();
      expect(foldersService.getHostFolders(), linuxResult);
    });
  });

  group("Windows FoldersService tests", () {
    setUpAll(() {
      when(mockPlatformService.isWindows).thenReturn(true);
    });

    test("Get cache folder path is correct", () {
      Directory cacheFolder =
          Directory("C:\\Users\\user\\AppData\\Roaming\\.takeoff\\");

      FoldersService foldersService = FoldersService();
      expect(foldersService.getCacheFolderPath(), cacheFolder.path);
    });

    test("Host folders are generated correctly", () {
      Map<String, String> windowsResult = {
        "gcloud": "C:\\Users\\user\\AppData\\Roaming\\gcloud",
        "aws": "C:\\Users\\user\\.aws",
        "azure": "C:\\Users\\user\\.azure",
        "kube": "C:\\Users\\user\\.kube",
        "github": "C:\\Users\\user\\AppData\\Roaming\\GitHub CLI",
        "ssh": "C:\\Users\\user\\.ssh",
        "workspace": "C:\\Users\\user\\hangar_workspace",
        "firebase": "C:\\Users\\user\\AppData\\Roaming\\configstore",
        "git": "C:\\Users\\user\\.gitconfig"
      };

      FoldersService foldersService = FoldersService();
      expect(foldersService.getHostFolders(), windowsResult);
    });
  });

  group("Unsupported platform test", () {
    setUpAll(() {
      when(mockPlatformService.isWindows).thenReturn(false);
      when(mockPlatformService.isUnix).thenReturn(false);
    });
    test("Get cache folder is correct", () {
      try {
        FoldersService foldersService = FoldersService();
        foldersService.getCacheFolderPath();
        fail("Unsupported Platform Exception should have been thrown");
      } on UnsupportedPlatformException {
        expect(true, true);
      }
    });

    test("Host folders are generated correctly", () {
      try {
        FoldersService foldersService = FoldersService();
        foldersService.getHostFolders();
        fail("Unsupported Platform Exception should have been thrown");
      } on UnsupportedPlatformException {
        expect(true, true);
      }
    });
  });
}
