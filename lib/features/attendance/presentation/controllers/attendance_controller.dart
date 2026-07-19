import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../data/models/attendance_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../../core/config/service_locator.dart';

class AttendanceState {
  final AttendanceModel? todayRecord;
  final List<AttendanceModel> history;
  final bool isLoading;
  final String? errorMessage;

  AttendanceState({
    this.todayRecord,
    this.history = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AttendanceState copyWith({
    AttendanceModel? todayRecord,
    bool clearTodayRecord = false,
    List<AttendanceModel>? history,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AttendanceState(
      todayRecord: clearTodayRecord ? null : (todayRecord ?? this.todayRecord),
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AttendanceController extends StateNotifier<AttendanceState> {
  final AttendanceRepository _attendanceRepository;
  final String? _employeeId;
  final String? _companyId;

  AttendanceController(this._attendanceRepository, this._employeeId, this._companyId)
      : super(AttendanceState()) {
    if (_employeeId != null) {
      loadTodayStatus();
      loadHistory();
    }
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadTodayStatus() async {
    if (_employeeId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final dateStr = _getTodayDate();
      final record = await _attendanceRepository.getTodayStatus(_employeeId!, dateStr);
      state = state.copyWith(todayRecord: record, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> loadHistory() async {
    if (_employeeId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final history = await _attendanceRepository.getHistory(_employeeId!);
      state = state.copyWith(history: history, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> clockIn({double? lat, double? lng, bool qrVerified = false}) async {
    if (_employeeId == null || _companyId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final now = DateTime.now();
      final record = AttendanceModel(
        employeeId: _employeeId!,
        companyId: _companyId!,
        date: _getTodayDate(),
        clockIn: now,
        gpsLatIn: lat,
        gpsLngIn: lng,
        qrVerifiedIn: qrVerified,
        status: now.hour >= 9 ? 'late' : 'present', // simple threshold rule
      );

      await _attendanceRepository.clockIn(record);
      await loadTodayStatus();
      await loadHistory();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> clockOut({double? lat, double? lng, bool qrVerified = false}) async {
    final today = state.todayRecord;
    if (today == null || today.id == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _attendanceRepository.clockOut(
        id: today.id!,
        time: DateTime.now(),
        lat: lat,
        lng: lng,
        qrVerified: qrVerified,
      );
      await loadTodayStatus();
      await loadHistory();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}

// Attendance provider mapped with active authenticated user credentials
final attendanceControllerProvider =
    StateNotifierProvider<AttendanceController, AttendanceState>((ref) {
  final authState = ref.watch(authControllerProvider);
  String? employeeId;
  String? companyId;

  if (authState is AuthAuthenticated) {
    employeeId = authState.user.id;
    companyId = authState.user.companyId;
  }

  return AttendanceController(
    sl<AttendanceRepository>(),
    employeeId,
    companyId,
  );
});
