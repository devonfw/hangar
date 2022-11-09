import 'package:takeoff_cli/output/log.dart';

class TakeOffCli {
  void run(List<String> args) {
    print("here");

    Log.info("message");
    Log.debug("message");
    Log.error("message");
    Log.warning("message");
    Log.success("message");
  }
}
