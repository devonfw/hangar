import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_provider_header.dart';

void main() async {
  setUpAll(() async {});

  Widget createApp(Widget body) {
    return MaterialApp(
      home: Scaffold(
        body: body,
      ),
    );
  }

  testWidgets('Headers has IconButton', (tester) async {
    String providerName = "testProviderName";
    await tester.pumpWidget(createApp(CloudProviderHeader(
        authAccount: "",
        name: providerName,
        authenticateCallback: () => true)));

    expect(find.byIcon(Icons.login_outlined), findsOneWidget);
  });
  testWidgets('Headers without authenticated user', (tester) async {
    String providerName = "testProviderName";
    await tester.pumpWidget(createApp(CloudProviderHeader(
        authAccount: "",
        name: providerName,
        authenticateCallback: () => true)));

    expect(find.text("Not authenticated"), findsOneWidget);
  });

  testWidgets('Headers without authenticated user', (tester) async {
    String providerName = "testProviderName";
    String userAccount = "user@mail.com";
    await tester.pumpWidget(createApp(CloudProviderHeader(
        name: providerName,
        authAccount: userAccount,
        authenticateCallback: () => true)));

    expect(find.text(userAccount), findsOneWidget);
  });

  testWidgets('Headers without authenticated user', (tester) async {
    String providerName = "testProviderName";
    String userAccount = "user@mail.com";
    bool testVar = false;
    await tester.pumpWidget(createApp(CloudProviderHeader(
        name: providerName,
        authAccount: userAccount,
        authenticateCallback: () => testVar = true)));

    expect(testVar, false);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(testVar, true);
  });
}
