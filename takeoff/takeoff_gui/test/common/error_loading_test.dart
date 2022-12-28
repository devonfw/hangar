import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:takeoff_gui/common/error_loading_page.dart';

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

  testWidgets('Widget error widget', (tester) async {
    // Avoid overflow due to test conditions
    FlutterError.onError = null;
    String messageText = "TestText";
    IconData icon = Icons.warning_amber_outlined;
    await tester.pumpWidget(createApp(ErrorLoadingPage(message: messageText)));
    expect(find.text(messageText), findsOneWidget);
    expect(find.byIcon(icon), findsOneWidget);
  });
}
