import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_projects_list.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_project_item.dart';
import 'package:takeoff_gui/mocks/mock_projects.dart';
import '../../../common/test_widget.dart';
import 'cloud_projects_list_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProjectsController>()])
void main() async {
  setUpAll(() {
    MockProjectsController mockController = MockProjectsController();
    GetIt.I.registerSingleton<ProjectsController>(mockController);
  });

  testWidgets('Show projects with account', (tester) async {
    String nameList = "AWS";

    await tester.pumpWidget(TestWidget(
        child: CloudProjectsList(
            name: nameList,
            authAccount: "test@mail.com",
            projects: MockProjects.projectsAWS,
            authenticateCallback: () => true,
            logOutCallback: () => true)));
    await tester.pumpAndSettle();
    expect(find.text(nameList), findsOneWidget);
    expect(find.byType(CloudProjectItem), findsWidgets);
  });

  testWidgets('Hide projects if not logged', (tester) async {
    String nameList = "AWS";

    await tester.pumpWidget(TestWidget(
        child: CloudProjectsList(
            name: nameList,
            authAccount: "",
            projects: MockProjects.projectsAWS,
            authenticateCallback: () => true,
            logOutCallback: () => true)));
    expect(find.text(nameList), findsOneWidget);
    expect(find.byType(CloudProjectItem), findsNothing);
  });
}
