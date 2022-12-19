import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:takeoff_gui/common/loading_page.dart';

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

  testWidgets('Widget loading page', (tester) async {
    // Avoid overflow due to test conditions
    String text =
        "Launching the app, please while checking the requirements...";
    ImageProvider image = const AssetImage("assets/gifs/rocket.gif");
    await tester.pumpWidget(createApp(const LoadingPage()));
    expect(find.text(text), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.widgetWithImage(Image, image), findsNothing);
  });
}
