import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_gui/domain/project.dart';
import 'package:takeoff_gui/features/details/pages/project_details.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

import '../../common/test_widget.dart';
import 'project_details_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProjectsController>()])
void main() async {
  MockProjectsController mockProjectsController = MockProjectsController();
  final Project project =
      Project(name: "TestProject", cloud: CloudProviderId.gcloud);

  setUpAll(() async {
    GetIt.I.registerSingleton<ProjectsController>(mockProjectsController);
    when(mockProjectsController.selectedProject).thenReturn(project);
  });

  testWidgets('Widget loading page', (tester) async {
    String text = "${project.name} project resources";
    await tester.pumpWidget(TestWidget(child: ProjectDetails()));
    expect(find.text(text), findsOneWidget);
  });
}
