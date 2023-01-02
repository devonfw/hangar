import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/domain/project.dart';
import 'package:takeoff_gui/features/details/widgets/clean_dialog.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

import '../../../common/test_widget.dart';
import '../project_details_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProjectsController>()])
void main() async {
  MockProjectsController mockProjectsController = MockProjectsController();
  final Project project =
      Project(name: "TestProject", cloud: CloudProviderId.gcloud);

  setUpAll(() async {
    GetIt.I.registerSingleton<ProjectsController>(mockProjectsController);
    when(mockProjectsController.selectedProject).thenReturn(project);
  });

  testWidgets('Widget has correct text', (tester) async {
    await tester.pumpWidget(TestWidget(child: CleanDialog()));
    expect(find.text("Remove project"), findsOneWidget);
    expect(
        find.text(
            "The project will be deleted from local cache, but not remove from cloud."),
        findsOneWidget);
    expect(find.text("Once removed, you won't be able to add it again."),
        findsOneWidget);
    expect(find.text("Remove"), findsOneWidget);
    expect(find.text("Close"), findsOneWidget);

    await tester.pumpWidget(TestWidget(
        child: CustomButton(
            text: 'Remove', icon: Icons.remove, onPressed: () => {})));
    await tester.pumpWidget(TestWidget(
        child: CustomButton(
            text: 'Close', icon: Icons.close, onPressed: () => {})));
  });
}
