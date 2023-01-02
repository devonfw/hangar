//@GenerateNiceMocks([])
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart' as mobx;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_gui/common/monitor/pages/monitor_dialog.dart';
import 'package:takeoff_gui/features/create/utils/create_message.dart';
import 'package:takeoff_gui/features/create/utils/type_message.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

import '../../test_widget.dart';
import 'monitor_dialog_test.mocks.dart';

@GenerateNiceMocks(
    [MockSpec<MonitorController>(), MockSpec<ProjectsController>()])
void main() async {
  final MockMonitorController mockMonitorController = MockMonitorController();
  final MockProjectsController mockProjectsController =
      MockProjectsController();
  late MonitorDialog monitorDialog;

  setUpAll(() async {
    GetIt.I.registerSingleton<MonitorController>(mockMonitorController);
    GetIt.I.registerSingleton<ProjectsController>(mockProjectsController);
    monitorDialog = MonitorDialog();
  });

  testWidgets('Widget has correct data when Project is created and success',
      (tester) async {
    CreateMessage message =
        CreateMessage(TypeMessage.success, "Test message - isSuccess = true");

    when(mockMonitorController.outputChannel).thenReturn(StreamController());
    when(mockMonitorController.steps)
        .thenReturn(mobx.ObservableList.of([message]));
    when(mockMonitorController.hasFinished).thenReturn(true);
    when(mockMonitorController.isSuccess).thenReturn(true);
    await tester.pumpWidget(TestWidget(child: MonitorDialog()));

    expect(find.text("Project creation finished"), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);
    expect(find.byIcon(Icons.browser_updated_outlined), findsOneWidget);
    expect(find.text("Open project"), findsOneWidget);
  });

  testWidgets('Widget has correct data when Project is created and not success',
      (tester) async {
    CreateMessage message =
        CreateMessage(TypeMessage.success, "Test message - isSuccess = false");

    when(mockMonitorController.outputChannel).thenReturn(StreamController());
    when(mockMonitorController.steps)
        .thenReturn(mobx.ObservableList.of([message]));
    when(mockMonitorController.hasFinished).thenReturn(true);
    when(mockMonitorController.isSuccess).thenReturn(false);
    await tester.pumpWidget(TestWidget(child: MonitorDialog()));

    expect(find.text("Project creation finished"), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);
    expect(find.byIcon(Icons.browser_updated_outlined), findsOneWidget);
    expect(find.text("Close"), findsOneWidget);
  });

  testWidgets('Widget has correct data when Creating project...',
      (tester) async {
    CreateMessage message =
        CreateMessage(TypeMessage.success, "Test message - success");

    when(mockMonitorController.outputChannel).thenReturn(StreamController());
    when(mockMonitorController.steps)
        .thenReturn(mobx.ObservableList.of([message]));
    when(mockMonitorController.hasFinished).thenReturn(false);
    await tester.pumpWidget(TestWidget(child: MonitorDialog()));

    expect(find.text("Creating project..."), findsOneWidget);
  });
}
