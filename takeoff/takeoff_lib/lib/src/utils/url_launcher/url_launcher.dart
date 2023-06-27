import 'dart:io';

class UrlLaucher {
  /// Opens a given URL in the browser
  Future<ProcessResult> launch(String url) {
    if (Platform.isWindows) {
      return Process.run("powershell", ["-command", 'Start-Process "$url"']);
    } else if (Platform.isLinux) {
      return Process.run("xdg-open", [url], runInShell: true);
    } else if (Platform.isMacOS) {
      return Process.run("open", [url], runInShell: true);
    } else {
      throw UnsupportedError('OS not supported');
    }
  }
}
