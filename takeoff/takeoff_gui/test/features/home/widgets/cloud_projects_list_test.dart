import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_projects_list.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_provider_item.dart';
import 'package:takeoff_gui/mocks/mock_projects.dart';

void main() async {
  Widget createApp(Widget body) {
    return MaterialApp(
      home: Scaffold(
        body: body,
      ),
    );
  }

  testWidgets('Show projects with account', (tester) async {
    String nameList = "AWS";

    await tester.pumpWidget(createApp(CloudProjectsList(
        name: nameList,
        authAccount: "test@mail.com",
        projects: MockProjects.projectsAWS,
        authenticateCallback: () => true,
        logOutCallback: () => true)));
    expect(find.text(nameList), findsOneWidget);
    expect(find.byType(CloudProjectItem), findsWidgets);
  });

  testWidgets('Hide projects if not logged', (tester) async {
    String nameList = "AWS";

    await tester.pumpWidget(createApp(CloudProjectsList(
        name: nameList,
        authAccount: "",
        projects: MockProjects.projectsAWS,
        authenticateCallback: () => true,
        logOutCallback: () => true)));
    expect(find.text(nameList), findsOneWidget);
    expect(find.byType(CloudProjectItem), findsNothing);
  });
}
