import 'dart:io' show Directory, FileSystemException, Platform;

import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:takeoff_lib/src/utils/platform/unsupported_platform_exception.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class FoldersService {
  static List<String> hostFolderNames = [
    "gcloud",
    "aws",
    "azure",
    "kube",
    "github",
    "ssh"
  ];

  static Map<String, String> containerFolders = {
    "gcloud": "/root/.config/gcloud",
    "aws": "/root/.aws",
    "azure": "/root/.azure",
    "kube": "/root/.kube",
    "github": "/root/.config/gh",
    "ssh": "/root/.ssh"
  };

  /// Returns the Cache folder as a file. It it does not exists, it's created.
  ///
  /// If executed in non-desktop platforms throws an [UnsupportedPlatformException]
  static Directory getCacheFolder() {
    Directory cacheFolder = Directory(_getCacheFolderPath());

    if (!cacheFolder.existsSync()) {
      try {
        cacheFolder.createSync(recursive: false);
        Log.info("Created folder $cacheFolder");
      } on FileSystemException catch (e) {
        Log.error("Cannot create folder in ${cacheFolder.path}\nException: $e");
        rethrow;
      }
    }

    return cacheFolder;
  }

  /// Returns the folder path where the database for cache will be located in
  /// each platform.
  ///
  /// If executed in non-desktop platforms throws an [UnsupportedPlatformException]
  static String _getCacheFolderPath() {
    Map<String, String> env = Platform.environment;

    if (PlatformService.isWindows) {
      return "${env["UserProfile"]}\\AppData\\Roaming\\.takeoff\\";
    } else if (PlatformService.isUnix) {
      return "${env["HOME"]}/.takeoff/";
    }

    throw UnsupportedPlatformException(
        "Only Linux, Windows and MacOS are supported");
  }

  /// Creates all the folders necessary to mount the volumes for persistency of the Hangar containers
  static bool createHostFolders() {
    Log.info("Checking host volume folders");

    Directory cacheDirectory = getCacheFolder();
    for (String folderName in hostFolderNames) {
      Directory newFolder = Directory(cacheDirectory.path + folderName);
      if (!newFolder.existsSync()) {
        try {
          newFolder.createSync();
        } on FileSystemException {
          Log.error("Could not create $folderName folder");
          return false;
        }
      }
    }

    Log.success("All volume folders are ready");

    return true;
  }

  /// Returns a Map where the key is the folder name and the values are the paths
  static Map<String, String> getHostFolders() {
    Directory cacheFolder = getCacheFolder();

    return Map.fromEntries(
        hostFolderNames.map((name) => MapEntry(name, cacheFolder.path + name)));
  }
}
