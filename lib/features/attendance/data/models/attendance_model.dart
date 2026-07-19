class AttendanceModel {
  final String? id;
  final String employeeId;
  final String companyId;
  final String date; // yyyy-MM-dd
  final DateTime clockIn;
  final DateTime? clockOut;
  final double? gpsLatIn;
  final double? gpsLngIn;
  final double? gpsLatOut;
  final double? gpsLngOut;
  final bool qrVerifiedIn;
  final bool qrVerifiedOut;
  final String status; // present, late, absent, half_day

  AttendanceModel({
    this.id,
    required this.employeeId,
    required this.companyId,
    required this.date,
    required this.clockIn,
    this.clockOut,
    this.gpsLatIn,
    this.gpsLngIn,
    this.gpsLatOut,
    this.gpsLngOut,
    this.qrVerifiedIn = false,
    this.qrVerifiedOut = false,
    required this.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String?,
      employeeId: json['employee_id'] as String,
      companyId: json['company_id'] as String,
      date: json['date'] as String,
      clockIn: DateTime.parse(json['clock_in'] as String),
      clockOut: json['clock_out'] != null ? DateTime.parse(json['clock_out'] as String) : null,
      gpsLatIn: json['gps_lat_in'] != null ? double.tryParse(json['gps_lat_in'].toString()) : null,
      gpsLngIn: json['gps_lng_in'] != null ? double.tryParse(json['gps_lng_in'].toString()) : null,
      gpsLatOut: json['gps_lat_out'] != null ? double.tryParse(json['gps_lat_out'].toString()) : null,
      gpsLngOut: json['gps_lng_out'] != null ? double.tryParse(json['gps_lng_out'].toString()) : null,
      qrVerifiedIn: json['qr_verified_in'] as bool? ?? false,
      qrVerifiedOut: json['qr_verified_out'] as bool? ?? false,
      status: json['status'] as String? ?? 'present',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employee_id': employeeId,
      'company_id': companyId,
      'date': date,
      'clock_in': clockIn.toIso8601String(),
      'clock_out': clockOut?.toIso8601String(),
      'gps_lat_in': gpsLatIn,
      'gps_lng_in': gpsLngIn,
      'gps_lat_out': gpsLatOut,
      'gps_lng_out': gpsLngOut,
      'qr_verified_in': qrVerifiedIn,
      'qr_verified_out': qrVerifiedOut,
      'status': status,
    };
  }
}
