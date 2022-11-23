import 'dart:io' show Directory, File, FileSystemException;
import 'package:meta/meta.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
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
    "ssh": ".ssh",
    "workspace": "hangar_workspace",
    "firebase": "AppData\\Roaming\\configstore",
    "git": ".gitconfig",
  };

  static Map<String, String> linuxHostFolders = {
    "gcloud": ".config/gcloud",
    "aws": ".aws",
    "azure": ".azure",
    "kube": ".kube",
    "github": ".config/gh",
    "ssh": ".ssh",
    "workspace": "hangar_workspace",
    "firebase": ".config/configstore",
    "git": ".gitconfig",
  };

  /// Names of the folders that will be created in .takeoff/
  static Map<String, String> containerFolders = {
    "gcloud": "/root/.config/gcloud",
    "aws": "/root/.aws",
    "azure": "/root/.azure",
    "kube": "/root/.kube",
    "github": "/root/.config/gh",
    "ssh": "/root/.ssh",
    "workspace": "/scripts/workspace",
    "firebase": "/root/.config/configstore",
    "git": "/root/.gitconfig",
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
    Map<String, String> env = platformService.env;

    late Map<String, String> hostFolders;
    late String baseFolder;

    if (platformService.isWindows) {
      hostFolders = windowsHostFolders;
      baseFolder = "${env["UserProfile"]}";
    } else if (platformService.isUnix) {
      hostFolders = linuxHostFolders;
      baseFolder = "${env["HOME"]}";
    } else {
      throw UnsupportedPlatformException(
          "Only Linux, Windows and MacOS are supported");
    }

    List<String> values = hostFolders.values.toList();
    // .gitconfig is a file, not a directory, so it does not need to be created
    values.remove(".gitconfig");
    File gitconfig = File(join(baseFolder, ".gitconfig"));
    if (!gitconfig.existsSync()) {
      try {
        gitconfig.createSync();
      } on FileSystemException {
        Log.error("Could not create .gitconfig file");
        return false;
      }
    }

    for (String folderName in values) {
      Directory newFolder = Directory(join(baseFolder, folderName));
      if (!newFolder.existsSync()) {
        try {
          newFolder.createSync(recursive: true);
        } on FileSystemException catch (e) {
          Log.error("Could not create $folderName folder: ${e.osError}");
          return false;
        }
      }
    }

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
