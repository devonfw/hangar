import 'dart:io';

import 'package:takeoff_lib/takeoff_lib.dart';

class TakeOffCli {
  void run(List<String> args) async {
    if (!await TakeOffFacade().checkEnvironment()) exit(1);
  }
}
