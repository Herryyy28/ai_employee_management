import 'package:flutter_test/flutter_test.dart';
import 'package:ai_employee_management/features/auth/data/models/user_model.dart';
import 'package:ai_employee_management/features/auth/domain/entities/user_entity.dart';
import 'package:ai_employee_management/features/attendance/data/models/attendance_model.dart';

void main() {
  group('Auth Model Serializations', () {
    test('Should convert UserModel to and from JSON correctly', () {
      final model = UserModel(
        id: 'user_uuid',
        companyId: 'company_uuid',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@company.com',
        role: UserRole.employee,
        status: 'active',
      );

      final json = model.toJson();
      expect(json['id'], 'user_uuid');
      expect(json['role'], 'employee');

      final parsed = UserModel.fromJson(json);
      expect(parsed.id, 'user_uuid');
      expect(parsed.firstName, 'John');
      expect(parsed.role, UserRole.employee);
    });

    test('Should parse UserRole enum options from Db strings correctly', () {
      expect(UserRole.fromString('super_admin'), UserRole.superAdmin);
      expect(UserRole.fromString('company_admin'), UserRole.companyAdmin);
      expect(UserRole.fromString('manager'), UserRole.manager);
      expect(UserRole.fromString('team_lead'), UserRole.teamLead);
      expect(UserRole.fromString('employee'), UserRole.employee);
      expect(UserRole.fromString('UNKNOWN_FALLBACK'), UserRole.employee);
    });
  });

  group('Attendance Model Serializations', () {
    test('Should parse check in dates and properties from raw map data', () {
      final now = DateTime.now();
      final model = AttendanceModel(
        employeeId: 'emp_1',
        companyId: 'comp_1',
        date: '2026-07-19',
        clockIn: now,
        status: 'present',
      );

      final json = model.toJson();
      expect(json['employee_id'], 'emp_1');
      expect(json['status'], 'present');
    });
  });
}
