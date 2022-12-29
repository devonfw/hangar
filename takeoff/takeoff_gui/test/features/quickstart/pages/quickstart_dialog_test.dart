import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_gui/features/create/controllers/project_form_controllers/google_form_controller.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:takeoff_gui/features/quickstart/pages/quickstart_dialog.dart';
import 'package:takeoff_gui/features/quickstart/utils/apps.dart';
import 'package:takeoff_gui/features/quickstart/widgets/quickstart_card.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

import '../../../common/test_widget.dart';
import 'quickstart_dialog_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<QuickstartController>(),
  MockSpec<GoogleFormController>(),
  MockSpec<TakeOffFacade>(),
])
void main() async {
  final MockQuickstartController mockQuickstartController =
      MockQuickstartController();
  final MockGoogleFormController mockGoogleFormController =
      MockGoogleFormController();
  final MockTakeOffFacade mockTakeOffFacade = MockTakeOffFacade();

  setUpAll(() async {
    GetIt.I.registerSingleton<QuickstartController>(mockQuickstartController);
    GetIt.I.registerSingleton<GoogleFormController>(mockGoogleFormController);
    GetIt.I.registerSingleton<TakeOffFacade>(mockTakeOffFacade);
  });

  testWidgets('Widget has text', (tester) async {
    when(mockQuickstartController.app).thenReturn(Apps.wayat);
    when(mockQuickstartController.region).thenReturn("asia-southeast1");
    when(mockQuickstartController.billingAccount)
        .thenReturn("3333-3333-3333-3333");

    await tester.pumpWidget(const TestWidget(
      child: QuickstartDialog(),
    ));
    expect(find.byType(QuickstartCard), findsWidgets);
    expect(find.byType(AssetImage), findsNothing);

    when(mockQuickstartController.app).thenReturn(Apps.viplane);
    await tester.pumpWidget(const TestWidget(
      child: QuickstartDialog(),
    ));
  });
}
