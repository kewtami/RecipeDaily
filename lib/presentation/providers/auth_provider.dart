import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Sign In
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(email, password, name);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

 // Login screen - existing users
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = _formatError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register screen - new users only
  Future<bool> signUpWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signUpWithGoogle();
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _error = _formatError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign Out with timeout
  Future<void> signOut() async {
    try {
      // Add timeout to prevent infinite loading
      await _authService.signOut().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Force local sign out even if server fails
        },
      );
      _user = null;
      notifyListeners();
    } catch (e) {
      // Force sign out locally even if there's an error
      _user = null;
      notifyListeners();
    }
  }

    String _formatError(String error) {
    // Remove "Exception: " prefix
    error = error.replaceAll('Exception: ', '');
    error = error.replaceAll('[firebase_auth/email-already-in-use] ', '');
    error = error.replaceAll('[firebase_auth/weak-password] ', '');
    error = error.replaceAll('[firebase_auth/invalid-email] ', '');
    error = error.replaceAll('[firebase_auth/wrong-password] ', '');
    error = error.replaceAll('[firebase_auth/user-not-found] ', '');
    error = error.replaceAll('[firebase_auth/too-many-requests] ', '');
    error = error.replaceAll('[firebase_auth/network-request-failed] ', '');
    
    return error;
  }
}