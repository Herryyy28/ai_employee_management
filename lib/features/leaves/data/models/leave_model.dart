class LeaveModel {
  final String? id;
  final String employeeId;
  final String companyId;
  final String leaveType; // casual, sick, earned, unpaid
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // pending, approved, rejected
  final String? approvedBy;
  final String? adminComments;

  LeaveModel({
    this.id,
    required this.employeeId,
    required this.companyId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = 'pending',
    this.approvedBy,
    this.adminComments,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'] as String?,
      employeeId: json['employee_id'] as String,
      companyId: json['company_id'] as String,
      leaveType: json['leave_type'] as String? ?? 'casual',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      approvedBy: json['approved_by'] as String?,
      adminComments: json['admin_comments'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employee_id': employeeId,
      'company_id': companyId,
      'leave_type': leaveType,
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate.toIso8601String().substring(0, 10),
      'reason': reason,
      'status': status,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (adminComments != null) 'admin_comments': adminComments,
    };
  }
}
