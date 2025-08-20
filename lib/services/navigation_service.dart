import 'package:carduible/ad/banner_ad.dart';
import 'package:carduible/services/animation.dart';
import 'package:carduible/widgets/control_page/control_page.dart';
import 'package:carduible/widgets/racing_page/loading_racing_page.dart';
import 'package:carduible/widgets/home_page/home_page.dart';
import 'package:carduible/widgets/settings_page/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final routerConfig = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  // initialLocation: '/home/racingPanel/0000',
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
            GoRoute(
              path: 'racingPanel/:deviceId',
              pageBuilder: (context, state) => const CustomTransitionPage(
                child: LoadingRacingPage(),
                transitionDuration: iosTransitionDuration,
                reverseTransitionDuration: iosReverseTransitionDuration,
                transitionsBuilder: iosTransitionsBuilder,
              ),
            ),
            GoRoute(
              path: 'settings',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: SettingsPage(),
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

  void goRacingPanel({required String deviceId}) {
    _router.go('/home/racingPanel/$deviceId');
  }

  void goSettings() {
    _router.go('/home/settings');
  }
}
