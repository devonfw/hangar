import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/utils/type_dialog.dart';
import 'package:takeoff_gui/features/home/widgets/auto_closing_dialog.dart';

import 'auto_closing_dialog_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProjectsController>()])
void main() async {
  MockProjectsController controller = MockProjectsController();
  setUpAll(() async {
    GetIt.I.registerSingleton<ProjectsController>(controller);
  });

  Widget createApp(Widget body) {
    return MaterialApp(
      home: Scaffold(
        body: body,
      ),
    );
  }

  testWidgets('Dialog has data', (tester) async {
    String title = "Test Title";
    String message = "Test message";
    await tester.pumpWidget(createApp(AutoClosingDialog(
        typeDialog: TypeDialog.info, title: title, message: message)));

    expect(find.text(title), findsOneWidget);
    expect(find.text(message), findsOneWidget);
    expect(find.text(title), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('Dialog info shows blue color', (tester) async {
    String title = "Test Title";
    String message = "Test message";
    await tester.pumpWidget(createApp(AutoClosingDialog(
        typeDialog: TypeDialog.info, title: title, message: message)));

    ElevatedButton button = tester.widget(find.byType(ElevatedButton));
    AlertDialog dialog = tester.widget(find.byType(AlertDialog));
    expect(button.style?.backgroundColor?.resolve(<MaterialState>{}),
        Colors.blue.shade400);
    expect(dialog.backgroundColor, Colors.blue.shade50);
  });

  testWidgets('Dialog error shows red color', (tester) async {
    String title = "Test Title";
    String message = "Test message";
    await tester.pumpWidget(createApp(AutoClosingDialog(
        typeDialog: TypeDialog.error, title: title, message: message)));

    ElevatedButton button = tester.widget(find.byType(ElevatedButton));
    AlertDialog dialog = tester.widget(find.byType(AlertDialog));
    expect(button.style?.backgroundColor?.resolve(<MaterialState>{}),
        Colors.red.shade600);
    expect(dialog.backgroundColor, Colors.red.shade200);
  });

  testWidgets('Dialog success shows green color', (tester) async {
    String title = "Test Title";
    String message = "Test message";
    await tester.pumpWidget(createApp(AutoClosingDialog(
        typeDialog: TypeDialog.success, title: title, message: message)));

    ElevatedButton button = tester.widget(find.byType(ElevatedButton));
    AlertDialog dialog = tester.widget(find.byType(AlertDialog));
    expect(button.style?.backgroundColor?.resolve(<MaterialState>{}),
        Colors.green.shade500);
    expect(dialog.backgroundColor, Colors.green.shade100);
  });

  testWidgets('Checks closes dialog', (tester) async {
    String title = "Test Title";
    String message = "Test message";
    await tester.pumpWidget(createApp(AutoClosingDialog(
        typeDialog: TypeDialog.success, title: title, message: message)));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.byType(AutoClosingDialog), findsNothing);
  });
}
