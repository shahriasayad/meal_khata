import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:meal_khata/app.dart';
import 'package:meal_khata/data/local/hive/hive_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final Directory tempDir = await Directory.systemTemp.createTemp(
      'meal_khata_test',
    );
    Hive.init(tempDir.path);
    await HiveService.instance.init();
  });

  testWidgets('App launches with dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MessApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Meals'), findsWidgets);
    expect(find.text('Expenses'), findsWidgets);
  });
}
