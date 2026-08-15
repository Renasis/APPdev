import 'dart:async';

import 'package:flutter/material.dart';

import '../models/support_inquiry_model.dart';
import '../repository/support_repository.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../authentication/models/auth_user_model.dart';

class SupportProvider extends ChangeNotifier {
  SupportProvider({
    SupportRepository? repository,
    AuthProvider? authProvider,
  })  : _repository = repository,
        _authProvider = authProvider {
    if (repository == null || authProvider == null) {
      return;
    }

    _authSubscription = authProvider.authStateChanges.listen((_) {
      if (authProvider.currentUser != null) {
        _loadInquiries(authProvider.currentUser!.id);
      }
    });

    if (authProvider.currentUser != null) {
      _loadInquiries(authProvider.currentUser!.id);
    }
  }

  final SupportRepository? _repository;
  final AuthProvider? _authProvider;

  StreamSubscription<List<SupportInquiryModel>>? _subscription;
  StreamSubscription<AuthUserModel?>? _authSubscription;

  final List<SupportInquiryModel> _inquiries = [];
  final List<SupportInquiryModel> _allInquiries = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<SupportInquiryModel> get inquiries => List.unmodifiable(_inquiries);
  List<SupportInquiryModel> get allInquiries => List.unmodifiable(_allInquiries);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _loadInquiries(String customerId) {
    _subscription?.cancel();
    _subscription = _repository?.watchCustomerInquiries(customerId).listen(
      (inquiries) {
        _inquiries
          ..clear()
          ..addAll(inquiries);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load inquiries.';
        notifyListeners();
      },
    );
  }

  Future<void> loadAllInquiries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository?.watchInquiries().listen(
      (inquiries) {
        _allInquiries
          ..clear()
          ..addAll(inquiries);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load inquiries.';
        notifyListeners();
      },
    );
  }

  Future<void> createInquiry({
    required String subject,
    required String message,
    required String category,
  }) async {
    final auth = _authProvider?.currentUser;
    if (auth == null) {
      _errorMessage = 'You must be logged in to submit an inquiry.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final inquiry = SupportInquiryModel(
        id: '',
        customerId: auth.id,
        subject: subject,
        message: message,
        category: category,
        status: 'Pending',
        createdAt: DateTime.now(),
      );

      await _repository?.createInquiry(inquiry, auth.id);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Failed to submit inquiry.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> replyToInquiry(String inquiryId, String reply) async {
    try {
      await _repository?.replyToInquiry(inquiryId, reply);
    } catch (error) {
      _errorMessage = 'Failed to reply to inquiry.';
      notifyListeners();
    }
  }

  Future<void> resolveInquiry(String inquiryId) async {
    try {
      await _repository?.resolveInquiry(inquiryId);
    } catch (error) {
      _errorMessage = 'Failed to resolve inquiry.';
      notifyListeners();
    }
  }

  Future<void> closeInquiry(String inquiryId) async {
    try {
      await _repository?.closeInquiry(inquiryId);
    } catch (error) {
      _errorMessage = 'Failed to close inquiry.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
