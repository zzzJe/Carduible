import 'package:eecamp/ad/banner_ad.dart';
import 'package:eecamp/services/animation.dart';
import 'package:eecamp/widgets/control_page/control_page.dart';
import 'package:eecamp/widgets/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final routerConfig = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    if (state.uri.path == '/') return '/home';
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: const BannerAdWidget(),
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const CustomTransitionPage(
            child: HomePage(),
            transitionDuration: iosTransitionDuration,
            reverseTransitionDuration: iosReverseTransitionDuration,
            transitionsBuilder: iosTransitionsBuilder,
          ),
          routes: <RouteBase>[
            GoRoute(
              path: 'controlPanel/:deviceId',
              pageBuilder: (context, state) => const CustomTransitionPage(
                child: ControlPage(),
                transitionDuration: iosTransitionDuration,
                reverseTransitionDuration: iosReverseTransitionDuration,
                transitionsBuilder: iosTransitionsBuilder,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

class NavigationService {
  late final GoRouter _router;

  NavigationService() {
    _router = routerConfig;
  }

  void goHome() {
    _router.go('/home');
  }

  void goControlPanel({required String deviceId}) {
    _router.go('/home/controlPanel/$deviceId');
  }
}
