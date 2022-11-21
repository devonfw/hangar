import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/common/custom_scroll_behaviour.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/navigation/app_router.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

void main() async {
  registerSingletons();
  runApp(const MyApp());
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

void registerSingletons() {
  TakeOffFacade facade = TakeOffFacade();
  facade.initialize();
  GetIt.I.registerSingleton<TakeOffFacade>(facade);
  GetIt.I.registerSingleton<ProjectsController>(ProjectsController());
  GetIt.I.registerLazySingleton<CreateController>(() => CreateController());
}
