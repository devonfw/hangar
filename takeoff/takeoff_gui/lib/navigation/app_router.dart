import 'package:go_router/go_router.dart';
import 'package:takeoff_gui/features/home/pages/home_page.dart';

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: "/",
    debugLogDiagnostics: true,
    routes: [GoRoute(path: "/", builder: (context, state) => const HomePage())],
  );
}