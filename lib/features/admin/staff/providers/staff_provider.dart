import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:pc_parts_application/features/admin/staff/services/staff_account_service.dart';
import 'package:pc_parts_application/features/authentication/providers/auth_provider.dart';

class StaffMember {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final bool isActive;
  final DateTime? createdAt;

  StaffMember({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.isActive,
    this.createdAt,
  });

  factory StaffMember.fromFirestore(Map<String, dynamic> data, String uid) {
    return StaffMember(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'staff',
      phone: data['phone'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phone': phone ?? '',
      'isActive': isActive,
    };
  }
}

class StaffProvider extends ChangeNotifier {
  StaffProvider(this._staffAccountService) {
    if (_authProvider != null && _authProvider!.isLoggedIn) {
      _loadStaff();
    }
  }

  final StaffAccountService _staffAccountService;
  AuthProvider? _authProvider;
  StreamSubscription<List<Map<String, dynamic>>>? _staffSubscription;

  final List<StaffMember> _staff = [];

  List<StaffMember> get staff => List.unmodifiable(_staff);

  bool get isLoading => _isLoading;
  bool _isLoading = false;
  String? get errorMessage => _errorMessage;
  String? _errorMessage;

  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (authProvider.isLoggedIn) {
      _loadStaff();
    }
  }

  Future<void> _loadStaff() async {
    _setLoading(true);
    try {
      _staffSubscription?.cancel();
      _staffSubscription = _staffAccountService.watchStaffAccounts().listen(
        (accounts) {
          _staff
            ..clear()
            ..addAll(
              accounts.map(
                (data) => StaffMember.fromFirestore(data, data['uid'] ?? data['id'] ?? ''),
              ),
            );
          _setLoading(false);
        },
        onError: (error) {
          _errorMessage = 'Failed to load staff.';
          _setLoading(false);
        },
      );
    } catch (error) {
      _errorMessage = 'Failed to load staff.';
      _setLoading(false);
    }
  }

  Future<void> createStaff({
    required String name,
    required String email,
    required String phone,
  }) async {
    _setLoading(true);
    try {
      final result = await _staffAccountService.createStaffAccount(
        name: name,
        email: email,
        phone: phone,
      );

      if (result['success'] == true) {
        _errorMessage = null;
      } else {
        _errorMessage = result['error'] ?? 'Failed to create staff.';
      }
    } catch (error) {
      _errorMessage = 'Failed to create staff.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStaff(StaffMember updatedMember) async {
    _setLoading(true);
    try {
      await _staffAccountService.updateStaffProfile(
        updatedMember.uid,
        updatedMember.toFirestore(),
      );
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Failed to update staff.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleStaffStatus(String uid) async {
    final index = _staff.indexWhere((member) => member.uid == uid);
    if (index == -1) return;

    final member = _staff[index];
    _setLoading(true);
    try {
      if (member.isActive) {
        final result = await _staffAccountService.disableStaffAccount(uid);
        if (result['success'] != true) {
          _errorMessage = result['error'] ?? 'Failed to update status.';
        }
      } else {
        final result = await _staffAccountService.enableStaffAccount(uid);
        if (result['success'] != true) {
          _errorMessage = result['error'] ?? 'Failed to update status.';
        }
      }
    } catch (error) {
      _errorMessage = 'Failed to update status.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteStaff(String uid) async {
    _setLoading(true);
    try {
      final result = await _staffAccountService.deleteStaffAccount(uid);
      if (result['success'] != true) {
        _errorMessage = result['error'] ?? 'Failed to delete staff.';
      }
    } catch (error) {
      _errorMessage = 'Failed to delete staff.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _staffSubscription?.cancel();
    super.dispose();
  }
}
