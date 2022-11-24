import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/common/custom_scroll_behaviour.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/common/error_loading_page.dart';
import 'package:takeoff_gui/common/loading_page.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
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
          if (snapshot.hasError) {
            return const ErrorLoadingPage(
                message:
                    "Some unexpected error happened, check docker daemon or try reinstalling the app.");
          } else if (snapshot.hasData) {
            if (!snapshot.data!) {
              return const ErrorLoadingPage(
                message:
                    'Docker daemon is not detected or the hangar docker image is not accessible. \n Launch the app again before check if daemon is running.',
              );
            }
            return MaterialApp.router(
              scrollBehavior: MyCustomScrollBehavior(),
              debugShowCheckedModeBanner: false,
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
  GetIt.I.registerLazySingleton<CreateController>(() => CreateController());
  GetIt.I.registerLazySingleton<QuickstartController>(
      () => QuickstartController());
}
