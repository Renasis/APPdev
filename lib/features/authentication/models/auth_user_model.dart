import 'package:pc_parts_application/core/enums/user_role.dart';

class AuthUserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;

  const AuthUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.role = UserRole.customer,
  });
}