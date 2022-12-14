import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:takeoff_gui/domain/project.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takeoff_lib/src/utils/url_launcher/resource_type.dart';

part 'projects_controller.g.dart';

// ignore: library_private_types_in_public_api
class ProjectsController = _ProjectsController with _$ProjectsController;

abstract class _ProjectsController with Store {
  final TakeOffFacade facade = GetIt.I.get<TakeOffFacade>();

  StreamController<List<int>> channel = StreamController();

  @observable
  Project? selectedProject;

  @observable
  bool waitForToken = false;

  @observable
  ObservableMap<CloudProviderId, List<Project>> projects = ObservableMap.of({
    CloudProviderId.aws: [],
    CloudProviderId.azure: [],
    CloudProviderId.gcloud: []
  });

  @observable
  ObservableMap<CloudProviderId, String> accounts = ObservableMap.of({
    CloudProviderId.aws: "",
    CloudProviderId.azure: "",
    CloudProviderId.gcloud: ""
  });

  @computed
  bool get isLogged {
    for (CloudProviderId cloud in accounts.keys) {
      if (accounts[cloud]!.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  @action
  Future<bool> initAccount(String email, CloudProviderId cloud) {
    late Future<bool> exitStatus =
        facade.init(email, CloudProviderId.gcloud, stdinStream: channel.stream);
    waitForToken = true;
    return exitStatus;
  }

  @action
  Future<void> updateInitAccounts() async {
    for (CloudProviderId cloud in CloudProviderId.values) {
      accounts[cloud] = await facade.getCurrentAccount(cloud);
      if (accounts[cloud]!.isNotEmpty) {
        projects[cloud] = (await facade.getProjects(cloud))
            .map((String e) => Project(name: e, cloud: cloud))
            .toList();
      }
    }
  }

  Future<void> logOut(CloudProviderId cloud) async {
    await facade.logOut(CloudProviderId.gcloud);
    await updateInitAccounts();
  }

  void resetChannel() {
    waitForToken = false;
    channel.close();
    channel = StreamController();
  }

  void openCLI() {
    Project? project = selectedProject;
    if (project != null) {
      facade.runProject(project.name, project.cloud);
    }
  }

  void clean() {
    Project? project = selectedProject;
    if (project != null) {
      facade.cleanProject(project.cloud, project.name);
    }
  }

  void openResource(ResourceType resourceType) async {
    Project? project = selectedProject;
    if (project != null) {
      Uri url = facade.getResource(project.name, project.cloud, resourceType);
      await _launchUrl(url);
    }
  }

  Future<bool> _launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      launchUrl(url);
      return true;
    } else {
      throw 'Could not launch $url';
    }
  }
}
