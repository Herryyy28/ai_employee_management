enum UserRole {
  superAdmin,
  companyAdmin,
  manager,
  teamLead,
  employee;

  String get name {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.companyAdmin:
        return 'Company Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.teamLead:
        return 'Team Lead';
      case UserRole.employee:
        return 'Employee';
    }
  }

  static UserRole fromString(String val) {
    switch (val.toLowerCase()) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'company_admin':
        return UserRole.companyAdmin;
      case 'manager':
        return UserRole.manager;
      case 'team_lead':
        return UserRole.teamLead;
      case 'employee':
      default:
        return UserRole.employee;
    }
  }

  String toDbString() {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.companyAdmin:
        return 'company_admin';
      case UserRole.manager:
        return 'manager';
      case UserRole.teamLead:
        return 'team_lead';
      case UserRole.employee:
        return 'employee';
    }
  }
}

class UserEntity {
  final String id;
  final String companyId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final UserRole role;
  final String? departmentId;
  final String? designationId;
  final String status;
  final String? profileImageUrl;

  const UserEntity({
    required this.id,
    required this.companyId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.role,
    this.departmentId,
    this.designationId,
    required this.status,
    this.profileImageUrl,
  });

  String get fullName => '$firstName $lastName';
}
