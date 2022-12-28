import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/widgets/google_login_dialog.dart';

import '../../../common/test_widget.dart';
import 'google_login_dialog_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProjectsController>()])
void main() async {
  MockProjectsController controller = MockProjectsController();
  setUpAll(() async {
    GetIt.I.registerSingleton<ProjectsController>(controller);
  });

  testWidgets('First step of login dialog', (tester) async {
    when(controller.waitForToken).thenReturn(false);
    await tester.pumpWidget(TestWidget(child: GoogleLoginDialog()));

    expect(find.text("Enter your google account:"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, "Login"), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, "Close"), findsOneWidget);
  });

  testWidgets('Second step of login dialog', (tester) async {
    when(controller.waitForToken).thenReturn(true);
    await tester.pumpWidget(TestWidget(child: GoogleLoginDialog()));

    expect(find.text("Enter your token:"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(
        find.widgetWithText(ElevatedButton, "Confirm token"), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, "Close"), findsOneWidget);
  });

  testWidgets('Check doLogin', (tester) async {
    when(controller.waitForToken).thenReturn(false);
    await tester.pumpWidget(TestWidget(child: Builder(builder: (context) {
      return ElevatedButton(
        child: const Text("openDialog"),
        onPressed: () => showDialog(
            context: context, builder: (context) => GoogleLoginDialog()),
      );
    })));

    await tester.tap(find.widgetWithText(ElevatedButton, "openDialog"));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, "Login"));
    await tester.pumpAndSettle();

    verify(controller.initAccount(any, any)).called(1);
    verify(controller.updateInitAccounts()).called(1);
  });
}
