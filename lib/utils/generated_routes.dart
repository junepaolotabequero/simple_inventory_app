import 'package:flutter_application_1/views/registration.dart';
import 'package:go_router/go_router.dart';

import '../constants/routes.dart';
import '../views/login.dart';
import '../views/splash.dart';
import '../views/success.dart';

class RouteGenerate {
  final GoRouter router = GoRouter(
      urlPathStrategy: UrlPathStrategy.path,
      debugLogDiagnostics: true,
      routes: <GoRoute>[
        GoRoute(
          name: Routes.splash,
          path: '/',
          builder: (context, state) => const Success(),
        ),
        GoRoute(
          name: Routes.register,
          path: '/register',
          builder: (context, state) => const Registration(),
        ),
        GoRoute(
          name: Routes.login,
          path: '/login',
          builder: (context, state) => const Login(),
        ),
        GoRoute(
          name: Routes.success,
          path: '/success',
          builder: (context, state) => const Success(),
        ),
      ]);
}
