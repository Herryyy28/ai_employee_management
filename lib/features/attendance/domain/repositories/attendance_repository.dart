import '../../data/models/attendance_model.dart';

abstract class AttendanceRepository {
  Future<void> clockIn(AttendanceModel attendance);
  
  Future<void> clockOut({
    required String id,
    required DateTime time,
    double? lat,
    double? lng,
    bool qrVerified = false,
  });

  Future<List<AttendanceModel>> getHistory(String employeeId);

  Future<AttendanceModel?> getTodayStatus(String employeeId, String date);
}
