import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.companyId,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phone,
    required super.role,
    super.departmentId,
    super.designationId,
    required super.status,
    super.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'employee'),
      departmentId: json['department_id'] as String?,
      designationId: json['designation_id'] as String?,
      status: json['status'] as String? ?? 'active',
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'role': role.toDbString(),
      'department_id': departmentId,
      'designation_id': designationId,
      'status': status,
      'profile_image_url': profileImageUrl,
    };
  }
}
