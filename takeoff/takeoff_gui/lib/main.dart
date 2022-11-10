import 'package:flutter/material.dart';
import 'package:takeoff_gui/common/custom_scroll_behaviour.dart';
import 'package:takeoff_gui/navigation/app_router.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    AppRouter appRouter = AppRouter();
    return MaterialApp.router(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter.router,
    );
  }
}
