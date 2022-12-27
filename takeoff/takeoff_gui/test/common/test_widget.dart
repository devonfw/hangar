import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:takeoff_gui/common/custom_scroll_behaviour.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TestWidget extends StatelessWidget {
  final Widget child;
  const TestWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: "/",
      debugLogDiagnostics: true,
      routes: [
        GoRoute(path: "/", builder: (context, state) => Scaffold(body: child)),
      ],
    );

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
