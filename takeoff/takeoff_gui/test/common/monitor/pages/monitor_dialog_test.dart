//@GenerateNiceMocks([])
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_gui/common/monitor/pages/monitor_dialog.dart';

import '../../test_widget.dart';
import 'monitor_dialog_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MonitorController>(),
])
void main() async {
  final MockMonitorController mockMonitorController = MockMonitorController();

  setUpAll(() async {
    GetIt.I.registerSingleton<MonitorController>(mockMonitorController);
  });

  // testWidgets('Widget has correct data', (tester) async {
  //   await tester.pumpWidget(TestWidget(child: MonitorDialog()));

  //   when(mockMonitorController.hasFinished).thenReturn(true);
  //   expect(find.text("Project creation finished"), findsOneWidget);
  //   expect(find.byType(CustomButton), findsOneWidget);
  //   expect(find.byIcon(Icons.browser_updated_outlined), findsOneWidget);
  //   when(mockMonitorController.isSuccess).thenReturn(true);
  //   expect(find.text("Open project"), findsOneWidget);
  //   when(mockMonitorController.isSuccess).thenReturn(false);
  //   expect(find.text("Close"), findsOneWidget);

  //   when(mockMonitorController.hasFinished).thenReturn(false);
  //   expect(find.text("Creating project..."), findsOneWidget);
  //   expect(find.byType(Container), findsOneWidget);
  // });
}
