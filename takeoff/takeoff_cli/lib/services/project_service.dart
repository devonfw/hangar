// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/takeoff_lib.dart';

class ProjectsService {
  final TakeOffFacade _takeOffFacade;
  ProjectsService(
    this._takeOffFacade,
  );

  Future<void> initAccount(String cloud, String email) async {
    CloudProviderId cloudProvider = CloudProviderId.fromString(cloud);
    await _takeOffFacade.init(email, cloudProvider);
  }

  Future<void> listProjects(String cloud) async {
    CloudProviderId providerId = CloudProviderId.fromString(cloud);
    CloudProvider provider = CloudProvider.fromId(providerId);

    if ((await _takeOffFacade.getCurrentAccount(providerId)).isEmpty) {
      Log.error("You have not logged in with ${provider.name}");
      return;
    }

    List<String> projects = await _takeOffFacade.getProjects(providerId);

    if (projects.isEmpty) {
      Log.warning("No projects created with ${provider.name}");
      return;
    }
    print("Projects from ${provider.name}:");
    for (var element in projects) {
      print(element);
    }
  }
}
