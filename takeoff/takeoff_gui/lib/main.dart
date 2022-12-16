import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/common/custom_scroll_behaviour.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/common/error_loading_page.dart';
import 'package:takeoff_gui/common/loading_page.dart';
import 'package:takeoff_gui/features/create/controllers/project_form_controllers/project_form_controllers.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:takeoff_gui/l10n/locale_constants.dart';
import 'package:takeoff_gui/navigation/app_router.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import 'package:desktop_window/desktop_window.dart';


void main() async {
  await registerSingletons();
  runApp(const MyApp());
  await DesktopWindow.setMinWindowSize(const Size(1200, 800));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: GetIt.I.get<TakeOffFacade>().initialize(),
        builder: (context, snapshot) {
          final localization = lookupAppLocalizations(LocaleConstants.getLocale());
          if (snapshot.hasError) {
            return ErrorLoadingPage(
                message: localization.errorDockerDaemon);
          } else if (snapshot.hasData) {
            if (!snapshot.data!) {
              return ErrorLoadingPage(
                message:
                    localization.errorContainerNotDetected,
              );
            }
            return MaterialApp.router(
              onGenerateTitle: (context) =>
      AppLocalizations.of(context)!.appTitle,
              scrollBehavior: MyCustomScrollBehavior(),
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: AppRouter().router,
            );
          } else {
            return const LoadingPage();
          }
        });
  }
}

Future<void> registerSingletons() async {
  TakeOffFacade facade = TakeOffFacade();
  GetIt.I.registerSingleton<TakeOffFacade>(facade);
  GetIt.I.registerSingleton<ProjectsController>(ProjectsController());
  GetIt.I.registerLazySingleton<MonitorController>(() => MonitorController());
  GetIt.I.registerLazySingleton<CreateController>(() => CreateController());
  GetIt.I.registerLazySingleton<QuickstartController>(
      () => QuickstartController());
  GetIt.I.registerLazySingleton<GoogleFormController>(
      () => GoogleFormController());
  GetIt.I.registerLazySingleton<AwsFormController>(() => AwsFormController());
  GetIt.I
      .registerLazySingleton<AzureFormController>(() => AzureFormController());
}
