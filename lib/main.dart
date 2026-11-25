
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  runApp(const WalletWaveApp());
}

class WalletWaveApp extends StatelessWidget {
  const WalletWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WalletWave',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}
