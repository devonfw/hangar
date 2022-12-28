import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/features/create/controllers/project_form_controllers/google_form_controller.dart';
import 'package:takeoff_gui/features/create/pages/create_dialog.dart';
import 'package:takeoff_gui/features/create/utils/languages_versions.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

import '../../common/test_widget.dart';
import 'create_dialog_test.mocks.dart';

@GenerateNiceMocks(
    [MockSpec<CreateController>(), MockSpec<GoogleFormController>()])
void main() async {
  MockCreateController mockProjectsController = MockCreateController();
  MockGoogleFormController mockGoogleFormController =
      MockGoogleFormController();

  setUpAll(() async {
    GetIt.I.registerSingleton<CreateController>(mockProjectsController);
    GetIt.I.registerSingleton<GoogleFormController>(mockGoogleFormController);
  });

  //   final List<DropdownButtonFormField<Language>> listItems =
  //     items.map<DropdownButtonFormField<Language>>((Language e) {
  //   return DropdownButtonFormField<Language>(
  //     key: ValueKey<Language>(e),
  //     value: e,
  //     child: Text(e.name, key: ValueKey<Language>(e)),
  //   );
  // }).toList();

  testWidgets('Widget has correct text', (tester) async {
    when(mockGoogleFormController.projectName).thenReturn("TestProjectName");
    when(mockGoogleFormController.billingAccount)
        .thenReturn("0000-0000-0000-0000");
    when(mockGoogleFormController.region).thenReturn("europe-west2");

    when(mockProjectsController.backendLanguage).thenReturn(Language.python);
    when(mockProjectsController.backendVersion).thenReturn(LanguagesVersions
        .versionsLanguages[LanguagesVersions.backendLanguages.first]!.first);

    when(mockProjectsController.frontendLanguage).thenReturn(Language.flutter);
    when(mockProjectsController.frontendVersion).thenReturn(LanguagesVersions
        .versionsLanguages[LanguagesVersions.frontendLanguages.first]!.first);

    await tester.pumpWidget(TestWidget(child: CreateDialog()));
    expect(find.text("Create a project"), findsOneWidget);
  });
}
