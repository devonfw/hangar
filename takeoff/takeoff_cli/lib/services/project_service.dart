// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/takeoff_lib.dart';

class ProjectsService {
  final TakeOffFacade _takeOffFacade;
  ProjectsService(
    this._takeOffFacade,
  );

  Future<void> initAccount(String cloud, String email) async {
    switch (cloud) {
      case "gc":
        _takeOffFacade.init(email, CloudProviderId.gcloud);
        break;
      case "aws":
        Log.warning("Not implemented yet");
        break;
      case "azure":
        Log.warning("Not implemented yet");
        break;
    }
  }
}
