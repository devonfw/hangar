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
        authenticateCallback: () => true,
        logOutCallback: () => true)));

    expect(find.byIcon(Icons.login_outlined), findsOneWidget);
  });
  testWidgets('Headers without authenticated user', (tester) async {
    String providerName = "testProviderName";
    await tester.pumpWidget(createApp(CloudProviderHeader(
        authAccount: "",
        name: providerName,
        authenticateCallback: () => true,
        logOutCallback: () => true)));

    expect(find.text("Not authenticated"), findsOneWidget);
  });

  testWidgets('Headers with authenticated user', (tester) async {
    String providerName = "testProviderName";
    String userAccount = "user@mail.com";
    await tester.pumpWidget(createApp(CloudProviderHeader(
        name: providerName,
        authAccount: userAccount,
        authenticateCallback: () => true,
        logOutCallback: () => true)));

    expect(find.text(userAccount), findsOneWidget);
  });

  testWidgets('Auth callback is called', (tester) async {
    String providerName = "";
    String userAccount = "";
    bool testVar = false;
    await tester.pumpWidget(createApp(CloudProviderHeader(
        name: providerName,
        authAccount: userAccount,
        authenticateCallback: () => testVar = true,
        logOutCallback: () => testVar = false)));

    expect(testVar, false);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(testVar, true);
  });

  testWidgets('LogOut callback is called', (tester) async {
    String providerName = "testProviderName";
    String userAccount = "user@mail.com";
    bool testVar = false;
    await tester.pumpWidget(createApp(CloudProviderHeader(
        name: providerName,
        authAccount: userAccount,
        authenticateCallback: () => testVar = false,
        logOutCallback: () => testVar = true)));

    expect(testVar, false);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(testVar, true);
  });
}
