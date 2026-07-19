class HiveBoxKeys {
  HiveBoxKeys._();

  // Box for auth credentials and user settings locally
  static const String authBox = 'auth_box';
  
  // Cache boxes for dashboard metrics & employee profiles
  static const String profileBox = 'profile_box';
  static const String dashboardBox = 'dashboard_box';

  // Offline operation queue box for sync service
  static const String offlineQueueBox = 'offline_queue_box';

  // Specific features local storage
  static const String attendanceBox = 'attendance_box';
  static const String tasksBox = 'tasks_box';
  static const String leavesBox = 'leaves_box';

  // Enterprise Suite local storage
  static const String enterpriseSettingsBox = 'enterprise_settings_box';
  static const String documentsBox = 'documents_box';
  static const String assetsBox = 'assets_box';
  static const String collaborationBox = 'collaboration_box';
  static const String wellnessBox = 'wellness_box';

  // Helper values
  static const String userSessionKey = 'user_session';
  static const String userProfileKey = 'user_profile';
  static const String tenantIdKey = 'tenant_id';
}

