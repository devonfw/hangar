import 'dart:io' show Platform;

class PlatformService {
  Map<String, String> get env => Platform.environment;
  bool get isWindows => Platform.isWindows;
  bool get isLinux => Platform.isLinux;
  bool get isMacOS => Platform.isMacOS;
  bool get isUnix => Platform.isLinux || Platform.isMacOS;
}
