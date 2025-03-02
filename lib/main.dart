import 'package:eecamp/providers/bluetooth_provider.dart';
import 'package:eecamp/services/navigation_service.dart';
import 'package:eecamp/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  // RequestConfiguration requestConfiguration = RequestConfiguration(
  //   testDeviceIds: <String>['0a8ecf8d-644f-4ae3-9416-1620345f4d38', '012b0fef-d3a5-483e-9fe7-c03e559a1278'],
  // );
  // MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const InitProvider());
}

class InitProvider extends StatelessWidget {
  const InitProvider({super.key});

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