import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_gui/features/create/controllers/project_form_controllers/create_form_controller.dart';
import 'package:takeoff_gui/features/create/controllers/project_form_controllers/project_form_controllers.dart';
import 'package:takeoff_gui/features/create/utils/cloud_providers_comb.dart';
import 'package:takeoff_gui/features/create/utils/languages_versions.dart';
import 'package:takeoff_gui/features/create/utils/provider_ci_cd.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

part 'create_controller.g.dart';

// ignore: library_private_types_in_public_api
class CreateController = _CreateController with _$CreateController;

abstract class _CreateController with Store {
  final MonitorController monitorController = GetIt.I.get<MonitorController>();

  @computed
  CreateFormController get formController {
    switch (cloudProvider) {
      case CloudProviderId.gcloud:
        return GetIt.I.get<GoogleFormController>();
      case CloudProviderId.aws:
        return GetIt.I.get<AwsFormController>();
      case CloudProviderId.azure:
        return GetIt.I.get<AzureFormController>();
    }
  }

  @observable
  CloudProviderId cloudProvider = CloudProviderId.gcloud;

  @observable
  ProviderCICD repoProvider = ProviderCICD.gcloud;

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

  @computed
  List<ProviderCICD> get providersCICD =>
      CloudProvidersComb.cicd[cloudProvider]!;

  @computed
  bool get isValid {
    return formController.isValid &&
        (backendLanguage != Language.none || frontendLanguage != Language.none);
  }

  @action
  void setCloudProvider(CloudProviderId cloud) {
    cloudProvider = cloud;
    repoProvider = CloudProvidersComb.cicd[cloudProvider]![0];
  }

  void createProject() async {
    monitorController.monitorProcess(() async => formController.create());
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
    frontendLanguage = LanguagesVersions.frontendLanguages[0];
    frontendVersion = LanguagesVersions
        .versionsLanguages[LanguagesVersions.frontendLanguages[0]]![0];
    backendLanguage = LanguagesVersions.backendLanguages[0];
    backendVersion = LanguagesVersions
        .versionsLanguages[LanguagesVersions.backendLanguages[0]]![0];
    formController.resetForm();
    monitorController.resetChannel();
  }
}
