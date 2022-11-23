import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart' as mobx;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:takeoff_gui/domain/project.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/pages/home_page.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_projects_list.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

import 'home_page_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProjectsController>()])
void main() async {
  MockProjectsController controller = MockProjectsController();
  // Avoid overflow due to test conditions
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

  testWidgets('Widget test', (tester) async {
    FlutterError.onError = null;
    when(controller.accounts)
        .thenReturn(mobx.ObservableMap<CloudProviderId, String>.of({
      CloudProviderId.aws: "",
      CloudProviderId.azure: "",
      CloudProviderId.gcloud: "",
    }));

    when(controller.projects)
        .thenReturn(mobx.ObservableMap<CloudProviderId, List<Project>>.of({
      CloudProviderId.aws: [],
      CloudProviderId.azure: [],
      CloudProviderId.gcloud: [],
    }));
    await tester.pumpWidget(createApp(HomePage()));

    expect(find.byType(CloudProjectsList), findsNWidgets(3));
  });
}
