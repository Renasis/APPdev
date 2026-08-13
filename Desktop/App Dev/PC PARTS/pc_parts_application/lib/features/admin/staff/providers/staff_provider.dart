import 'package:flutter/material.dart';

class StaffMember {
  final String id;
  final String name;
  final String email;
  final String role;
  bool isActive;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });
}

class StaffProvider extends ChangeNotifier {
  final List<StaffMember> _staff = [
    StaffMember(
      id: 'ST-001',
      name: 'Juan Dela Cruz',
      email: 'juan@example.com',
      role: 'Staff',
      isActive: true,
    ),
    StaffMember(
      id: 'ST-002',
      name: 'Maria Santos',
      email: 'maria@example.com',
      role: 'Staff',
      isActive: true,
    ),
  ];

  List<StaffMember> get staff => _staff;

  void addStaff(
    StaffMember member,
  ) {
    _staff.add(member);
    notifyListeners();
  }

  void updateStaff(
    StaffMember updatedMember,
  ) {
    final index = _staff.indexWhere(
      (member) => member.id == updatedMember.id,
    );

    if (index != -1) {
      _staff[index] = updatedMember;
      notifyListeners();
    }
  }

  void deleteStaff(
    String id,
  ) {
    _staff.removeWhere(
      (member) => member.id == id,
    );

    notifyListeners();
  }

  void toggleStaffStatus(
    String id,
  ) {
    final index = _staff.indexWhere(
      (member) => member.id == id,
    );

    if (index != -1) {
      _staff[index].isActive =
          !_staff[index].isActive;

      notifyListeners();
    }
  }
}