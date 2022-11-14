import 'dart:io' show Directory, FileSystemException;
import 'package:meta/meta.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/utils/platform/platform_service.dart';
import 'package:takeoff_lib/src/utils/platform/unsupported_platform_exception.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

/// Service that provides all the necessary folders for the application
class FoldersService {
  PlatformService platformService = GetIt.I.get<PlatformService>();

  /// Names of the folders that will be created in .takeoff/
  static Map<String, String> windowsHostFolders = {
    "gcloud": "AppData\\Roaming\\gcloud",
    "aws": ".aws",
    "azure": ".azure",
    "kube": ".kube",
    "github": "AppData\\Roaming\\GitHub CLI",
    "ssh": ".ssh"
  };

  static Map<String, String> linuxHostFolders = {
    "gcloud": ".config/gcloud",
    "aws": ".aws",
    "azure": ".azure",
    "kube": ".kube",
    "github": ".config/gh",
    "ssh": ".ssh"
  };

  /// Names of the folders that will be created in .takeoff/
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
  Directory getCacheFolder() {
    Directory cacheFolder = Directory(getCacheFolderPath());

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
  @visibleForTesting
  String getCacheFolderPath() {
    Map<String, String> env = platformService.env;

    if (platformService.isWindows) {
      return "${env["UserProfile"]}\\AppData\\Roaming\\.takeoff\\";
    } else if (platformService.isUnix) {
      return "${env["HOME"]}/.takeoff/";
    }

    throw UnsupportedPlatformException(
        "Only Linux, Windows and MacOS are supported");
  }

  /// Creates all the folders necessary to mount the volumes for persistency of the Hangar containers
  bool createHostFolders() {
    Log.info("Checking host volume folders");

    Directory cacheDirectory = getCacheFolder();
    for (String folderName in windowsHostFolders.values) {
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
  Map<String, String> getHostFolders() {
    Map<String, String> env = platformService.env;

    if (platformService.isWindows) {
      return Map.fromEntries(windowsHostFolders.entries.map((entry) =>
          MapEntry(entry.key, "${env["UserProfile"]}\\${entry.value}")));
    } else if (platformService.isUnix) {
      return Map.fromEntries(linuxHostFolders.entries.map(
          (entry) => MapEntry(entry.key, "${env["HOME"]}/${entry.value}")));
    }

    throw UnsupportedPlatformException(
        "Only Linux, Windows and MacOS are supported");
  }
}
