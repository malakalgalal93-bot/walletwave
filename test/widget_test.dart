import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:walletwave/main.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets(
    'WalletWave app starts successfully',
    (WidgetTester tester) async {
      await tester.pumpWidget(const WalletWaveApp());
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('WalletWave'), findsOneWidget);
    },
  );
}