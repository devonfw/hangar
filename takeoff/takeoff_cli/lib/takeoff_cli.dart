import 'package:takeoff_lib/takeoff_lib.dart';

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
