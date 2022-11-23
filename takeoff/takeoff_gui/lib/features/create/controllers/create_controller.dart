import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:takeoff_gui/features/create/utils/cloud_providers_comb.dart';
import 'package:takeoff_gui/features/create/utils/create_message.dart';
import 'package:takeoff_gui/features/create/utils/languages_versions.dart';
import 'package:takeoff_gui/features/create/utils/provider_ci_cd.dart';
import 'package:takeoff_gui/features/create/utils/type_message.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

part 'create_controller.g.dart';

// ignore: library_private_types_in_public_api
class CreateController = _CreateController with _$CreateController;

abstract class _CreateController with Store {
  final TakeOffFacade facade = GetIt.I.get<TakeOffFacade>();

  StreamController<String> channel = StreamController();

  @observable
  CloudProviderId cloudProvider = CloudProviderId.gcloud;

  @observable
  ProviderCICD repoProvider = ProviderCICD.gcloud;

  @observable
  ObservableList<CreateMessage> createSteps = ObservableList.of([]);

  @observable
  String projectName = "";

  @observable
  String projectUrl = "";

  @observable
  String region = "";

  @observable
  String billingAccount = "";

  @observable
  Language frontendLanguage = LanguagesVersions.frontendLanguages[0];

  @observable
  String frontendVersion = LanguagesVersions
      .versionsLanguages[LanguagesVersions.frontendLanguages[0]]![0];

  @observable
  Language backendLanguage = LanguagesVersions.backendLanguages[0];

  @observable
  String backendVersion = LanguagesVersions
      .versionsLanguages[LanguagesVersions.backendLanguages[0]]![0];

  @observable
  String googleCloudRegion = "";

  @computed
  List<ProviderCICD> get providersCICD =>
      CloudProvidersComb.cicd[cloudProvider]!;

  @action
  void setCloudProvider(CloudProviderId cloud) {
    cloudProvider = cloud;
    repoProvider = CloudProvidersComb.cicd[cloudProvider]![0];
  }

  @computed
  bool get hasFinished {
    List<TypeMessage> messages =
        createSteps.map((element) => element.typeMessage).toList();
    return messages.contains(TypeMessage.error) ||
        messages.contains(TypeMessage.success);
  }

  bool get isSuccess {
    List<TypeMessage> messages =
        createSteps.map((element) => element.typeMessage).toList();
    return messages.contains(TypeMessage.success);
  }

  void createProject() async {
    channel.stream.listen((event) {
      if (event.contains("http")) {
        projectUrl = event;
        createSteps.add(
            CreateMessage(TypeMessage.success, "Project create succesfully"));
      } else {
        createSteps.add(CreateMessage(TypeMessage.info, event));
      }
    });
    try {
      await facade.createProjectGCloud(
          projectName: projectName,
          billingAccount: billingAccount,
          backendLanguage: backendLanguage,
          backendVersion: backendVersion,
          frontendLanguage: frontendLanguage,
          frontendVersion: frontendVersion,
          googleCloudRegion: region,
          infoStream: channel);
    } catch (e) {
      createSteps.add(CreateMessage(TypeMessage.error, e.toString()));
    }
  }

  @action
  void setFrontendLanguage(Language lang) {
    frontendLanguage = lang;
    frontendVersion = LanguagesVersions.versionsLanguages[frontendLanguage]![0];
  }

  @action
  void setBackendLanguage(Language lang) {
    backendLanguage = lang;
    backendVersion = LanguagesVersions.versionsLanguages[backendLanguage]![0];
  }

  @action
  void resetForm() {
    cloudProvider = CloudProviderId.gcloud;
    repoProvider = ProviderCICD.gcloud;
    projectName = "";
    billingAccount = "";
    region = "";
    frontendLanguage = LanguagesVersions.frontendLanguages[0];
    frontendVersion = LanguagesVersions
        .versionsLanguages[LanguagesVersions.frontendLanguages[0]]![0];
    backendLanguage = LanguagesVersions.backendLanguages[0];
    backendVersion = LanguagesVersions
        .versionsLanguages[LanguagesVersions.backendLanguages[0]]![0];
    createSteps = ObservableList.of([]);
    resetChannel();
  }

  void resetChannel() {
    channel.close();
    channel = StreamController();
  }
}
