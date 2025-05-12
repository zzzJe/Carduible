import 'package:carduible/providers/bluetooth_provider.dart';
import 'package:carduible/providers/settings_provider.dart';
import 'package:carduible/services/navigation_service.dart';
import 'package:carduible/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  final buttonSettingsProvider = ButtonSettingsProvider();
  await buttonSettingsProvider.loadSettings();
  runApp(InitProvider(buttonSettingsProvider: buttonSettingsProvider));
}

class InitProvider extends StatelessWidget {
  const InitProvider({super.key, required this.buttonSettingsProvider});
  final ButtonSettingsProvider buttonSettingsProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NavigationService>(
          create: (_) => NavigationService(),
        ),
        ChangeNotifierProvider(
          create: (_) => BluetoothProvider(),
        ),
        ChangeNotifierProvider.value(value: buttonSettingsProvider),
      ],
      child: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: routerConfig,
      theme: ThemeData(useMaterial3: true, colorScheme: MaterialTheme.lightScheme()),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: MaterialTheme.darkScheme()),
    );
  }
}