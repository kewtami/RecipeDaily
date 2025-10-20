import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  
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

  // Google Sign In
  // Future<bool> signInWithGoogle() async {
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();

  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
  //     if (googleUser == null) {
  //       _isLoading = false;
  //       notifyListeners();
  //       return false;
  //     }

  //     final GoogleSignInAuthentication googleAuth = 
  //         await googleUser.authentication;

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     UserCredential userCredential = 
  //         await FirebaseAuth.instance.signInWithCredential(credential);

  //     // Bước 4: Tạo UserModel
  //     _user = UserModel(
  //       id: userCredential.user!.uid,
  //       email: userCredential.user!.email!,
  //       displayName: userCredential.user!.displayName,
  //       photoURL: userCredential.user!.photoURL,
  //     );

  //     _isLoading = false;
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     _error = e.toString();
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }

  // Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
    // await _googleSignIn.signOut();
    _user = null;
    notifyListeners();
  }
}