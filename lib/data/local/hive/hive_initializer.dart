import 'package:hive_flutter/hive_flutter.dart';

import 'hive_service.dart';

class HiveInitializer {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await HiveService.instance.init();
  }

  HiveInitializer._();
}
