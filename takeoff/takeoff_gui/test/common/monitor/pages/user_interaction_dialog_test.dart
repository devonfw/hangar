//@GenerateNiceMocks([])
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_gui/common/monitor/pages/user_interaction_dialog.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

import '../../test_widget.dart';
import 'user_interaction_dialog_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MonitorController>(),
])
void main() async {
  final MockMonitorController mockMonitorController = MockMonitorController();

  setUpAll(() async {
    GetIt.I.registerSingleton<MonitorController>(mockMonitorController);
  });

  testWidgets('Widget has correct data', (tester) async {
    GuiMessage guiMessage =
        GuiMessage(type: MessageType.info, message: "Test Message");
    UserInteractionDialog userInteractionDialog =
        UserInteractionDialog(message: guiMessage);

    userInteractionDialog.message.inputType = InputType.text;
    userInteractionDialog.message.url = "Test url";

    await tester.pumpWidget(
        TestWidget(child: UserInteractionDialog(message: guiMessage)));

    expect(find.text("Please, follow these steps"), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text("Open link"), findsOneWidget);
    expect(find.text("Confirm"), findsOneWidget);
    expect(find.byIcon(Icons.check_box), findsWidgets);

    userInteractionDialog.message.inputType = null;
    await tester.tap(find.text("Open link"));
    await tester.pumpAndSettle();

    // await tester.tap(find.text("Confirm"));
    // await tester.pumpAndSettle();
  });
}
