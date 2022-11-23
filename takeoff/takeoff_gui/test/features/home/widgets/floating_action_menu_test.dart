import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/widgets/custom_floating_button.dart';
import 'package:takeoff_gui/features/home/widgets/floating_action_menu.dart';
import 'floating_action_menu_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProjectsController>()])
void main() async {
  Widget createApp(Widget floatingMenu) {
    return MaterialApp(
      home: Scaffold(
        body: const Text(""),
        floatingActionButton: floatingMenu,
      ),
    );
  }

  setUp(() {
    MockProjectsController controller = MockProjectsController();
    GetIt.I.registerSingleton<ProjectsController>(controller);
  });

  testWidgets('Two action buttons for create and quickstart', (tester) async {
    // Avoid overflow due to test conditions
    FlutterError.onError = null;
    await tester.pumpWidget(createApp(FloatingActionMenu()));
    expect(find.byType(CustomFloatingButton), findsNWidgets(2));
    expect(find.text("Create"), findsOneWidget);
    expect(find.text("QuickStart"), findsOneWidget);
  });
}
