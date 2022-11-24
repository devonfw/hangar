// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/takeoff_lib.dart';

class ProjectsService {
  final TakeOffFacade _takeOffFacade;
  ProjectsService(
    this._takeOffFacade,
  );

  Future<void> initAccount(CloudProviderId cloudProvider, String email) async {
    await _takeOffFacade.init(email, cloudProvider);
  }

  Future<void> listProjects(CloudProviderId cloudProvider) async {
    CloudProvider provider = CloudProvider.fromId(cloudProvider);

    if ((await _takeOffFacade.getCurrentAccount(cloudProvider)).isEmpty) {
      Log.error("You have not logged in with ${provider.name}");
      return;
    }

    List<String> projects = await _takeOffFacade.getProjects(cloudProvider);

    if (projects.isEmpty) {
      Log.warning("No projects created with ${provider.name}");
      return;
    }
    print("Projects from ${provider.name}:");
    for (var element in projects) {
      print(element);
    }
  }

  Future<void> createGoogleProject(
      {required String projectName,
      required String billingAccount,
      required Language backendLanguage,
      String? backendVersion,
      required Language frontendLanguage,
      String? frontendVersion,
      required String googleCloudRegion}) async {
    try {
      await _takeOffFacade.createProjectGCloud(
          projectName: projectName,
          billingAccount: billingAccount,
          backendLanguage: backendLanguage,
          backendVersion: backendVersion,
          frontendLanguage: frontendLanguage,
          frontendVersion: frontendVersion,
          googleCloudRegion: googleCloudRegion);
    } on CreateProjectException catch (e) {
      Log.error(e.message);
    }
  }

  Future<void> quickstartWayat(
      {required String billingAccount,
      required String googleCloudRegion}) async {
    try {
      await _takeOffFacade.quickstartWayat(
          billingAccount: billingAccount, googleCloudRegion: googleCloudRegion);
    } on CreateProjectException catch (e) {
      Log.error(e.message);
    }
  }

  Future<void> cleanProject(
      CloudProviderId cloudProviderId, String projectId) async {
    CloudProvider provider = CloudProvider.fromId(cloudProviderId);

    if ((await _takeOffFacade.getCurrentAccount(cloudProviderId)).isEmpty) {
      Log.error("You have not logged in with ${provider.name}");
      return;
    }

    List<String> projects = await _takeOffFacade.getProjects(cloudProviderId);

    if (!projects.contains(projectId)) {
      Log.error(
          "Project $projectId does not exist in TakeOff for ${provider.name}");
      return;
    }

    if (!await _takeOffFacade.cleanProject(cloudProviderId, projectId)) {
      Log.error("There was an error removing project $projectId");
    } else {
      Log.success("Cleaned all data from project $projectId");
    }
  }
}
