import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:takeoff_gui/features/create/controllers/project_form_controllers/google_form_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

import 'google_form_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TakeOffFacade>(),
])
void main() async {
  final MockTakeOffFacade mockTakeOffFacade = MockTakeOffFacade();
  late GoogleFormController googleFormController;

  setUpAll(() async {
    GetIt.I.registerSingleton<TakeOffFacade>(mockTakeOffFacade);
    googleFormController = GoogleFormController();
  });

  test('Test create project google cloud', () async {
    await googleFormController.create();
    bool result = await mockTakeOffFacade.createProjectGCloud(
        projectName: "TestProjectName",
        billingAccount: "0000-0000-0000-0000",
        googleCloudRegion: "europe-west1");
    expect(result, false);
  });

  test('Form is valid', () async {
    bool result = googleFormController.isValid;
    expect(result, false);
  });

  test('Test reset form', () async {
    googleFormController.resetForm();

    expect(googleFormController.projectName, "");
    expect(googleFormController.billingAccount, "");
    expect(googleFormController.region, "");
  });
}
