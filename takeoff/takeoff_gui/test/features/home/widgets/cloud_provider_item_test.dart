import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_provider_item.dart';
import 'package:takeoff_gui/mocks/mock_projects.dart';

void main() async {
  setUpAll(() async {});

  Widget createApp(Widget body) {
    return MaterialApp(
      home: Scaffold(
        body: body,
      ),
    );
  }

  testWidgets('Widget test', (tester) async {
    await tester.pumpWidget(
        createApp(CloudProjectItem(project: MockProjects.projectsAWS[0])));

    expect(find.text(MockProjects.projectsAWS[0].name), findsOneWidget);
  });
}
