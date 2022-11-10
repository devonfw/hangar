import 'dart:io' show Platform;

class PlatformService {
  static bool get isWindows => Platform.isWindows;
  static bool get isLinux => Platform.isLinux;
  static bool get isMacOS => Platform.isMacOS;
  static bool get isUnix => Platform.isLinux || Platform.isMacOS;
}
