import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takeoff_gui/common/icon_text_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// @GenerateMocks([ClassToMock])
void main() async {
  setUpAll(() async {});

  Widget createApp(Widget body) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale("en", "US");
      },
      home: Scaffold(
        body: body,
      ),
    );
  }

  testWidgets('Widget test', (tester) async {
    // Avoid overflow due to test conditions
    FlutterError.onError = null;
    String buttonText = "TestText";
    IconData icon = Icons.account_circle;
    await tester.pumpWidget(createApp(
      IconTextButton(
        text: buttonText,
        icon: icon,
        onPressed: () => true,
      ),
    ));
    await tester.pumpWidget(createApp(IconTextButton(
      icon: icon,
      text: buttonText,
    )));

    await tester.pumpAndSettle();

    expect(find.text(buttonText), findsOneWidget);
    expect(find.byIcon(icon), findsOneWidget);
  });
}
