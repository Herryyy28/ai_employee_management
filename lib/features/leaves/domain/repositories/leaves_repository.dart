import '../models/leave_model.dart';

abstract class LeavesRepository {
  Future<void> submitLeave(LeaveModel leave);
  
  Future<List<LeaveModel>> getLeaves(String employeeId);

  Future<List<LeaveModel>> getCompanyLeaves(String companyId);

  Future<void> updateLeaveStatus({
    required String id,
    required String status,
    required String approvedBy,
    String? comments,
  });
}
