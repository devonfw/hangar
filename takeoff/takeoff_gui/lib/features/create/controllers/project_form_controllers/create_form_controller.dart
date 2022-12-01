import 'dart:async';

import 'package:takeoff_lib/takeoff_lib.dart';

abstract class CreateFormController {
  bool get isValid;

  Future<void> create({
    Language? backendLanguage,
    String? backendVersion,
    Language? frontendLanguage,
    String? frontendVersion,
    StreamController<GuiMessage>? infoStream,
    StreamController<String>? inputStream,
  });

  void resetForm();
}
