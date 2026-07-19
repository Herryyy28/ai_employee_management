import 'package:hive_flutter/hive_flutter.dart';
import 'hive_keys.dart';

class HiveSetup {
  HiveSetup._();

  static Future<void> init() async {
    // 1. Initialize Hive for Flutter integration
    await Hive.initFlutter();

    // 2. Register type adapters if we define custom models later
    // e.g., Hive.registerAdapter(EmployeeAdapter());
    
    // 3. Open core boxes required for startup & offline functionality
    await Future.wait([
      Hive.openBox(HiveBoxKeys.authBox),
      Hive.openBox(HiveBoxKeys.profileBox),
      Hive.openBox(HiveBoxKeys.dashboardBox),
      Hive.openBox(HiveBoxKeys.offlineQueueBox),
      Hive.openBox(HiveBoxKeys.attendanceBox),
      Hive.openBox(HiveBoxKeys.tasksBox),
      Hive.openBox(HiveBoxKeys.leavesBox),
      Hive.openBox(HiveBoxKeys.enterpriseSettingsBox),
      Hive.openBox(HiveBoxKeys.documentsBox),
      Hive.openBox(HiveBoxKeys.assetsBox),
      Hive.openBox(HiveBoxKeys.collaborationBox),
      Hive.openBox(HiveBoxKeys.wellnessBox),
    ]);
  }

  // Clear all local caches (e.g. on logout)
  static Future<void> clearAllCache() async {
    await Future.wait([
      Hive.box(HiveBoxKeys.authBox).clear(),
      Hive.box(HiveBoxKeys.profileBox).clear(),
      Hive.box(HiveBoxKeys.dashboardBox).clear(),
      Hive.box(HiveBoxKeys.offlineQueueBox).clear(),
      Hive.box(HiveBoxKeys.attendanceBox).clear(),
      Hive.box(HiveBoxKeys.tasksBox).clear(),
      Hive.box(HiveBoxKeys.leavesBox).clear(),
      Hive.box(HiveBoxKeys.enterpriseSettingsBox).clear(),
      Hive.box(HiveBoxKeys.documentsBox).clear(),
      Hive.box(HiveBoxKeys.assetsBox).clear(),
      Hive.box(HiveBoxKeys.collaborationBox).clear(),
      Hive.box(HiveBoxKeys.wellnessBox).clear(),
    ]);
  }
}
