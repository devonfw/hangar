import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takeoff_gui/features/home/widgets/custom_floating_button.dart';
import 'package:takeoff_gui/features/home/widgets/floating_action_menu.dart';

void main() async {
  Widget createApp(Widget floatingMenu) {
    return MaterialApp(
      home: Scaffold(
        body: const Text(""),
        floatingActionButton: floatingMenu,
      ),
    );
  }

  testWidgets('Two action buttons for create and quickstart', (tester) async {
    // Avoid overflow due to test conditions
    FlutterError.onError = null;
    await tester.pumpWidget(createApp(const FloatingActionMenu()));
    expect(find.byType(CustomFloatingButton), findsNWidgets(2));
    expect(find.text("Create"), findsOneWidget);
    expect(find.text("QuickStart"), findsOneWidget);
  });
}
