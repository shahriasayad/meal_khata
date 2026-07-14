import 'package:flutter/material.dart';

import 'package:meal_khata/app.dart';
import 'package:meal_khata/data/local/hive/hive_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInitializer.initialize();
  runApp(const MessApp());
}
