// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthStatus _status = AuthStatus.unknown;
  UserModel? _userModel;
  String? _error;
  bool _isLoading = false;

  AuthStatus get status => _status;
  UserModel? get user => _userModel;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((event) async {
      if (event.session != null) {
        _status = AuthStatus.authenticated;
        await _fetchProfile();
      } else {
        _status = AuthStatus.unauthenticated;
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchProfile() async {
    try {
      _userModel = await _authService.fetchUserProfile();
    } catch (_) {}
  }

  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signUp(email: email, password: password);
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> deductCredit() async {
    try {
      _userModel = await _authService.deductCredit();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    await _fetchProfile();
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login credentials'))
      return 'Incorrect email or password.';
    if (raw.contains('already registered'))
      return 'This email is already in use.';
    if (raw.contains('Password should be'))
      return 'Password must be at least 6 characters.';
    print('SUPABASE AUTH ERROR: $raw');
    return raw; // Return raw string temporarily to debug
  }
}
