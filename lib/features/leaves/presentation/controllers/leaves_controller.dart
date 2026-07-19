import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/leaves_repository.dart';
import '../../data/models/leave_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../../../core/config/service_locator.dart';

class LeavesState {
  final List<LeaveModel> employeeLeaves;
  final List<LeaveModel> companyLeaves;
  final bool isLoading;
  final String? errorMessage;

  LeavesState({
    this.employeeLeaves = const [],
    this.companyLeaves = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  LeavesState copyWith({
    List<LeaveModel>? employeeLeaves,
    List<LeaveModel>? companyLeaves,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LeavesState(
      employeeLeaves: employeeLeaves ?? this.employeeLeaves,
      companyLeaves: companyLeaves ?? this.companyLeaves,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LeavesController extends StateNotifier<LeavesState> {
  final LeavesRepository _leavesRepository;
  final String? _employeeId;
  final String? _companyId;

  LeavesController(this._leavesRepository, this._employeeId, this._companyId) : super(LeavesState()) {
    loadLeaves();
    loadCompanyLeaves();
  }

  Future<void> loadLeaves() async {
    if (_employeeId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final list = await _leavesRepository.getLeaves(_employeeId!);
      state = state.copyWith(employeeLeaves: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> loadCompanyLeaves() async {
    if (_companyId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final list = await _leavesRepository.getCompanyLeaves(_companyId!);
      state = state.copyWith(companyLeaves: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> applyLeave({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    if (_employeeId == null || _companyId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final leave = LeaveModel(
        employeeId: _employeeId!,
        companyId: _companyId!,
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        status: 'pending',
      );
      await _leavesRepository.submitLeave(leave);
      await loadLeaves();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> reviewLeave({
    required String id,
    required String status, // approved, rejected
    required String reviewerId,
    String? comments,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _leavesRepository.updateLeaveStatus(
        id: id,
        status: status,
        approvedBy: reviewerId,
        comments: comments,
      );
      await loadCompanyLeaves();
      await loadLeaves();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}

// Leaves controller provider mapped with auth state credentials
final leavesControllerProvider = StateNotifierProvider<LeavesController, LeavesState>((ref) {
  final authState = ref.watch(authControllerProvider);
  String? employeeId;
  String? companyId;

  if (authState is AuthAuthenticated) {
    employeeId = authState.user.id;
    companyId = authState.user.companyId;
  }

  return LeavesController(
    sl<LeavesRepository>(),
    employeeId,
    companyId,
  );
});
