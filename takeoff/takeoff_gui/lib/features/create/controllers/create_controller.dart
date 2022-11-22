import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:takeoff_gui/features/create/utils/languages_versions.dart';
import 'package:takeoff_gui/features/create/utils/provider_ci_cd.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

part 'create_controller.g.dart';

// ignore: library_private_types_in_public_api
class CreateController = _CreateController with _$CreateController;

abstract class _CreateController with Store {
  final TakeOffFacade facade = GetIt.I.get<TakeOffFacade>();

  @observable
  CloudProviderId cloudProvider = CloudProviderId.gcloud;

  @observable
  ProviderCICD repoProvider = ProviderCICD.gcloud;

  @observable
  String projectName = "";

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

  void createProject() async {
    await facade.createProjectGCloud(
        projectName: projectName,
        billingAccount: billingAccount,
        backendLanguage: backendLanguage,
        frontendLanguage: frontendLanguage,
        googleCloudRegion: '');
    resetForm();
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
    frontendLanguage = LanguagesVersions.frontendLanguages[0];
    frontendVersion = LanguagesVersions
        .versionsLanguages[LanguagesVersions.frontendLanguages[0]]![0];
    backendLanguage = LanguagesVersions.backendLanguages[0];
    backendVersion = LanguagesVersions
        .versionsLanguages[LanguagesVersions.backendLanguages[0]]![0];
  }
}
