import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_project_item.dart';
import 'package:takeoff_gui/mocks/mock_projects.dart';
import 'cloud_provider_item_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProjectsController>()])
void main() async {
  setUpAll(() async {
    MockProjectsController mockController = MockProjectsController();
    GetIt.I.registerSingleton<ProjectsController>(mockController);
  });

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
