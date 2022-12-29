import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:takeoff_gui/features/create/controllers/project_form_controllers/google_form_controller.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';

import 'quickstart_dialog_test.mocks.dart';

@GenerateNiceMocks(
    [MockSpec<QuickstartController>(), MockSpec<GoogleFormController>()])
void main() async {
  MockQuickstartController mockQuickstartController =
      MockQuickstartController();
  MockGoogleFormController mockGoogleFormController =
      MockGoogleFormController();

  setUpAll(() async {
    GetIt.I.registerSingleton<QuickstartController>(mockQuickstartController);
    GetIt.I.registerSingleton<GoogleFormController>(mockGoogleFormController);
  });

  testWidgets('Widget has text', (tester) async {});
}
