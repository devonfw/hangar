import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takeoff_gui/common/custom_button.dart';

// @GenerateMocks([ClassToMock])
void main() async {
  setUpAll(() async {});

  Widget createApp(Widget floatingMenu) {
    return MaterialApp(
      home: Scaffold(
        body: const Text(""),
        floatingActionButton: floatingMenu,
      ),
    );
  }

  testWidgets('Widget test', (tester) async {
    // Avoid overflow due to test conditions
    FlutterError.onError = null;
    String buttonText = "TestText";
    IconData icon = Icons.access_alarm;
    bool testVar = false;
    await tester.pumpWidget(createApp(
      CustomButton(
        text: buttonText,
        icon: icon,
        onPressed: () => testVar = true,
      ),
    ));
    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();

    expect(find.text(buttonText), findsOneWidget);
    expect(find.byIcon(icon), findsOneWidget);
    expect(testVar, true);
  });
}
