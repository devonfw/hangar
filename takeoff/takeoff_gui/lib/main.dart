import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/common/custom_scroll_behaviour.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
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
    return MaterialApp.router(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter().router,
    );
  }
}

Future<void> registerSingletons() async {
  TakeOffFacade facade = TakeOffFacade();
  await facade.initialize();
  GetIt.I.registerSingleton<TakeOffFacade>(facade);
  GetIt.I.registerSingleton<ProjectsController>(ProjectsController());
}
