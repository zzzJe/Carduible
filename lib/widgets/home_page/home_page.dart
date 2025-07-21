import 'dart:io';
import 'package:carduible/providers/bluetooth_provider.dart';
import 'package:carduible/services/navigation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';

String debugDeviceId = 'DebugEECamp';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<BluetoothDevice> devicesList = [];
  StreamSubscription? scanSubscription;
  bool isScanning = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuart,
    ));
    checkPermissions();
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkPermissions() async {
    if (kIsWeb) {
      // Web platform does not require any permissions
      startScan();
    } else if (Platform.isIOS) {
      var locationPermission = await Permission.location.request();
      var bluetoothPermission = await Permission.bluetooth.request();

      if (locationPermission.isGranted && bluetoothPermission.isGranted) {
        startScan();
      } else if (!locationPermission.isGranted) {
        locationPermission = await Permission.location.request();
      } else if (!bluetoothPermission.isGranted) {
        bluetoothPermission = await Permission.bluetooth.request();
      } else {
        debugPrint("Permissions not granted\n");
      }
    } else if (Platform.isAndroid) {
      var locationPermission = await Permission.location.request();
      var bluetoothPermission = await Permission.bluetoothScan.request();

      if (locationPermission.isGranted && bluetoothPermission.isGranted) {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        }
        startScan();
      } else if (!locationPermission.isGranted) {
        locationPermission = await Permission.location.request();
      } else if (!bluetoothPermission.isGranted) {
        bluetoothPermission = await Permission.bluetoothScan.request();
      } else {
        debugPrint("Permissions not granted\n");
      }
    } else {
      debugPrint("Unsupported platform\n");
    }
  }

  Future<void> startScan() async {
    setState(() {
      isScanning = true;
    });

    _controller.repeat();

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          devicesList = results
              .map((r) => r.device)
              .where((device) => device.platformName != '') // 排除空名字裝置
              .toList();
        });
      }
    });

    await Future.delayed(const Duration(seconds: 15));
    if (mounted) {
      setState(() {
        isScanning = false;
      });
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            floating: false,
            stretch: true,
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Theme.of(context).colorScheme.onTertiary,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              centerTitle: true,
              title: Text(
                'Carduible',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              background: Image.asset(
                'assets/sliver_app_bar_background.png',
                fit: BoxFit.fitWidth,
              ),
            ),
            actions: [
              RotationTransition(
                turns: _animation,
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: isScanning ? null : checkPermissions,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Provider.of<NavigationService>(context, listen: false).goSettings();
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // 如果是最後一個 index，就顯示 debug item
                if (index == 0) {
                  return ListTile(
                    title: const Text('🛠 Debug'),
                    subtitle: const Text('Enter debugging mode'),
                    trailing: const Icon(Icons.bug_report),
                    tileColor: Theme.of(context).colorScheme.surfaceContainer,
                    onTap: () {
                      Provider.of<NavigationService>(context, listen: false)
                          .goControlPanel(deviceId: debugDeviceId);
                    },
                  );
                }

                // 否則就顯示一般裝置
                final device = devicesList[index - 1];
                return ListTile(
                  title: Text(device.platformName),
                  subtitle: Text(device.remoteId.toString()),
                  trailing: const Icon(Icons.bluetooth),
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  onTap: () {
                    Provider.of<BluetoothProvider>(context, listen: false)
                        .setSelectedDevice(device);
                    Provider.of<NavigationService>(context, listen: false)
                        .goControlPanel(deviceId: device.remoteId.toString());
                  },
                );
              },
              childCount: devicesList.length + 1, // 多加一個 for debug
            ),
          ),

          // SliverList(
          //   delegate: SliverChildBuilderDelegate(
          //     childCount: devicesList.length,
          //     (context, index) {
          //       return ListTile(
          //         title: Text(devicesList[index].platformName),
          //         subtitle: Text(devicesList[index].remoteId.toString()),
          //         trailing: const Icon(Icons.bluetooth),
          //         tileColor: Theme.of(context).colorScheme.surfaceContainer,
          //         onTap: () {
          //           Provider.of<BluetoothProvider>(context, listen: false)
          //               .setSelectedDevice(devicesList[index]);
          //           Provider.of<NavigationService>(context, listen: false)
          //               .goControlPanel(deviceId: devicesList[index].remoteId.toString());
          //         },
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
