import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/features/create/controllers/project_form_controllers/create_form_controller.dart';
import 'package:takeoff_gui/features/create/utils/provider_ci_cd.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

import 'create_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MonitorController>(),
  MockSpec<CreateFormController>(),
])
void main() async {
  final MockCreateFormController mockCreateFormController =
      MockCreateFormController();
  final MockMonitorController mockMonitorController = MockMonitorController();
  late CreateController createController;

  setUpAll(() async {
    GetIt.I.registerSingleton<MonitorController>(mockMonitorController);
    GetIt.I.registerSingleton<CreateFormController>(mockCreateFormController);
    createController = CreateController();
  });

  ///createProject cannot be tested because of asynchronic behavior and that the internal functions should be tested instead
  // test('Test create project google cloud', () async {
  //   await createController.createProject();
  //   verify(await mockCreateFormController.create(
  //           backendLanguage: Language.node,
  //           backendVersion: LanguagesVersions.backendLanguages.last.name,
  //           frontendLanguage: Language.angular,
  //           frontendVersion: LanguagesVersions.frontendLanguages.last.name))
  //       .called(1);
  // });

  test('Form is valid', () async {
    bool result = createController.isValid;
    expect(result, false);
  });

  test('Test set cloud provider', () async {
    CloudProviderId cloud = CloudProviderId.gcloud;
    createController.setCloudProvider(cloud);
    expect(createController.cloudProvider, cloud);
    expect(createController.repoProvider, ProviderCICD.gcloud);
  });

  test('Test set default frontend language', () async {
    Language lang = Language.angular;
    createController.setFrontendLanguage(lang);
    expect(createController.frontendLanguage.name, lang.name);
  });

  test('Test set default backend language', () async {
    Language lang = Language.quarkusJVM;
    createController.setBackendLanguage(lang);
    expect(createController.backendLanguage.name, lang.name);
  });

  test('Test reset form', () async {
    createController.resetForm();

    expect(createController.cloudProvider, CloudProviderId.gcloud);
    expect(createController.repoProvider, ProviderCICD.gcloud);
    expect(createController.frontendLanguage, Language.flutter);
    expect(createController.frontendVersion, '3.0.0');
    expect(createController.backendLanguage, Language.python);
    expect(createController.backendVersion, "3.9");
  });
}
